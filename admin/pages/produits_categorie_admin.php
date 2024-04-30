<?php
// Inclure les classes et initialisations nécessaires
require './src/php/utils/verifier_connexion.php';
require_once './src/php/db/dbPgConnect.php';
require_once './src/php/classes/Connexion.class.php';
require_once './src/php/classes/CommandeDB.class.php';


$cat = new CategorieDB($cnx);
$liste = $cat->getProduitsById_cat($_GET['id_categorie']);
$nbr = count($liste);

?>

<div><a href="index_.php?page=disconnect.php">Log out</a></div>
<div>
    <a href="?page=accueil_admin.php">Page Administrateur</a>
    <a href="?page=gestionProduits.php">Gestion des produits</a>
    <a href="?page=gestionCommandes.php">Gestion des commandes</a>

</div>

<div class="album py-5 bg-body-tertiary">
    <div class="container">
        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3">
            <?php for ($i = 0; $i < $nbr; $i++) : ?>
                <div class="col">
                    <div class="card shadow-sm">
                        <svg class="bd-placeholder-img card-img-top" width="100%" height="225"
                             xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Placeholder: Thumbnail"
                             preserveAspectRatio="xMidYMid slice" focusable="false">
                            <title>Placeholder</title>
                            <rect width="100%" height="100%" fill="#55595c"/>
                            <text x="50%" y="50%" fill="#eceeef" dy=".3em">Thumbnail</text>
                        </svg>
                        <div class="card-body">
                            <p class="card-text"><?php echo $liste[$i]->nom; ?></p>
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="btn-group">
                                    <!-- Ajouter un bouton avec un événement onclick pour appeler la fonction JavaScript -->

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            <?php endfor; ?>
        </div>
    </div>
</div>