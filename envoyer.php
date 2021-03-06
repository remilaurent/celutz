<?php
   if (array_key_exists('lat', $_GET) && array_key_exists('lon', $_GET)) {
     $lat = $_GET['lat'];
     $lon = $_GET['lon'];
   } else {
     $lat = '';
     $lon = '';
   }
?>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr">
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=UTF-8"/>
    <link type="image/x-icon" rel="shortcut icon" href="images/tsf.png"/>
    <link rel="stylesheet" media="screen" href="css/base.css" />
    <title>Envoi d'une image sur le serveur</title>
    <script src="js/send.js"></script>
    <script>
    window.onload = function() {
      link_file_to_input(document.getElementById('file'), 
                         document.getElementById('titre'));
    };
    </script>
  </head>
  <body id="main_body">
    <header>
      <h1><img src="images/tetaneutral.svg" alt="tetaneutral.net"/></h1>
    </header>
    <section id="main">
      <h2>Ajouter un nouveau panorama</h2>
      <form action="uploadReceive.php" method="post" enctype="multipart/form-data" id="upload">
	<ul>
	  <li>

		  <fieldset>
			<legend>Fichier image</legend>
			<input type="hidden" name="APC_UPLOAD_PROGRESS" id="progress_key"
			value="panoramas"/>
			<ul>
			  <li><input type="file" name="files[]" id="file" multiple="multiple"/>
		    <p class="help">
		  Le fichier à envoyer doit être une image de taille maximale 300 Mo ;
		  il peut s'agir d'un panorama (par exemple assemblé
		  avec <a href="http://hugin.sourceforge.net/">hugin</a>), ou d'une simple photo.
		    </p>
</li>

		    <li>
          <input type="text" name="titre" id="titre" placeholder="Titre" value=""/>
		<p class="help">Nom d'usage, explicite sur le lieu de prise de vue </p>
          
        </li>

			  <li><input type="checkbox" name="loop" value="true"> Panorama bouclant
			  (360°)
		      <p class="help">Ne sélectionner cette option que si les bords droite et gauche de l'image coïncident.</p>
</li>
			</ul>
		</fieldset>
	  </li>
	  <li>
		<fieldset>
	    <legend>Coordonnées (optionnel)</legend>
		<input type="text" name="lat" placeholder="latitude" value="<?php echo $lat; ?>"/>
		<input type="text" name="lon" placeholder="longitude" value="<?php echo $lon ?>"/>
		<input type="text" name="alt" placeholder="altitude (m)" width="20"/>
        <p class="help">
		  Si vous ne spécifiez pas les coordonnées maintenant, il sera
		  toujours possible de le faire plus tard.
		</p>
        </fieldset>
	  </li>
	  <li>
	    <input type="submit" name="submit" value="Envoyer" />
	  </li>
	</ul>
      </form>
      <a href="./index.php">Retour liste</a>
    </section>
    <footer class="validators"><samp>
	page validée par
	<a href="http://validator.w3.org/check?uri=referer"><img src="images/valid_xhtml.svg"
								 alt="Valid XHTML" title="xHTML validé !"/></a>
	<a href="http://jigsaw.w3.org/css-validator/check/referer"><img src="images/valid_css.svg"
									alt="CSS validé !" title="CSS validé !"/></a>
    </samp></footer>
  </body>
</html>
