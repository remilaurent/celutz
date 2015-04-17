#!/bin/sh

set -e
export LANG=C

trap terminate EXIT

test_mode=false
memory_limit=256
crop_x=256
crop_y=256
min_scale=0
max_scale=8
script="$(basename "$0")"
debug=false

log() {
    echo "$*" >&2
}

debug() {
    if [ "true" = "$debug" ]; then
        echo "$*" >&2
    fi
}

terminate() {
    log "got error"
    clean_tmp
}

clean_tmp() {
    if [ "$wfname" -o "$tmp_file" ]; then
        rm -f "$wfname" "$tmp_file"
    fi
}

usage() {
    log "$script [OPTION]... <image_to_convert>"
    log "  -x <x_tile_size>  : size of a tile (default is 256)"
    log "  -y <y_tile_size>  : size of a tile (default is 256)"
    log "  -p <prefix_result>: output name prefix, defaut split on '.'"
    log "  -m <min_zoom>     : min zoom/scale (default is 0)"
    log "  -M <max_zoom>     : max zoom/scale (default is 8)"
    log "  -t                : test_mode (default is false)"
    log "  -h                : this message"
    log "<image_to_convert>  : input image to convert"
    log "  example: $basename test_image.jpg"
}

if ! which anytopnm pnmscale convert bc > /dev/null; then
    log "il faut installer les paquets"
    log "  - netpbm"
    log "  - imagemagick"
    log "  - bc"
    log "pour utiliser ce script !"
    exit 1
fi

while getopts m:M:x:y:p:ht prs; do
    case $prs in
        t)        test_mode=true;;
        x)        crop_x=$OPTARG;;
        y)        crop_y=$OPTARG;;
        m)        min_scale=$OPTARG;;
        M)        max_scale=$OPTARG;;
        p)        prefix=$OPTARG;;
        \? | h)   echo -e "$usage"
                  exit 2;;
    esac
done
shift `expr $OPTIND - 1`

fname="$1"
dir="$(dirname "$fname")"

if [ ! "$fname" ]; then
    usage
    exit 1
elif [ ! -r "$fname" ]; then
    log "can't read input file '$fname'"
    exit 1
fi

if [ ! "$prefix" ]; then
    # only strip file extension
    prefix="$(basename "$fname" | sed 's/\.[^\.]*$//')"
fi

wfname="$(mktemp "${prefix}_XXXX.pnm")"
if [ "false" = "$test_mode" ]; then
    anytopnm "$fname" > "$wfname"
else
    log "anytopnm $fname > $wfname"
fi

tmp_file="$(mktemp)"

for z in $(seq "$min_scale" "$max_scale"); do
    fprefix="${prefix}_00$z"
    ratio="$(echo "scale=4; 1 / (2^$z)" | bc -l)"
    log "generating ratio $ratio"
    zwfname="$tmp_file"

    if [ "$z" = "0" ]; then
        zwfname="$wfname"
    else
        debug "pnmscale '$ratio' '$wfname' > '$zwfname'"
        if ! pnmscale "$ratio" "$wfname" > "$zwfname"; then
            log "pnmscale 'pnmscale $ratio $wfname > $zwfname' failed"
            exit 1
        fi
    fi
    debug "convert '$zwfname' " \
        "-limit memory '$memory_limit'" \
        "-crop '${crop_x}x${crop_x}'" \
        "-set filename:tile '%[fx:page.x/${crop_x}]_%[fx:page.y/${crop_y}]'" \
        "+repage +adjoin '${fprefix}_%[filename:tile].jpg'"
    if convert "$zwfname" \
        -limit memory "$memory_limit" \
        -crop "${crop_x}x${crop_x}" \
        -set filename:tile "%[fx:page.x/${crop_x}]_%[fx:page.y/${crop_y}]" \
        +repage +adjoin "${fprefix}_%[filename:tile].jpg"; then
        log "generated $(ls "${fprefix}_"*| wc -l) files"
    else
        log "convert failed"
        exit 2
    fi
done

if ! $test_mode; then
    rename 's/_(\d\d)_(\d+\.jpg)$/_0$1_$2/' ${prefix}_*
    rename 's/_(\d)_(\d+\.jpg)$/_00$1_$2/' ${prefix}_*
    rename 's/_(\d+)_(\d\d)(\.jpg)$/_$1_0$2$3/' ${prefix}_*
    rename 's/_(\d+)_(\d)(\.jpg)$/_$1_00$2$3/' ${prefix}_*
fi

trap '' EXIT
clean_tmp
