<?php
//toujours vérifier la qualité d'admin
require 'admin/src/php/utils/verif_client.php';
print "<br>Page d'accueil du client ";


$cat = new CategorieDB($cnx);
$liste = $cat->getAllCategories();
$nbr_cat = count($liste);

$clientDB = new ClientDB($cnx);
$panierDB = new PanierDB($cnx);
$clientId = $_SESSION['client'];

$clientInfo = $clientDB->getClientById($clientId);

if ($clientInfo) {
    $nomClient = $clientInfo['nom']; // Récupérer le nom du client depuis les informations récupérées
    echo "<p>Bonjour $nomClient !</p>"; // Afficher un message de bienvenue avec le nom du client
} else {
    echo "<p>Bonjour !</p>"; // Afficher un message de bienvenue générique
}


?>
    <nav id="menu">
        <?php
        if (file_exists('./src/php/utils/menu_public.php')) {
            include './src/php/utils/menu_public.php';
        }
        ?>

        <a href="index_.php?page=disconnect.php">Log out</a>
        <a href="?page=panier.php">Consulter votre panier</a>

    </nav>

    <div class="album py-5 bg-body-tertiary">
        <div class="container">
            <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3">
                <?php
                for ($i = 0; $i < $nbr_cat; $i++) {
                    ?>
                    <div class="col">
                        <div class="card shadow-sm">
                            <svg class="bd-placeholder-img card-img-top" width="100%" height="225"
                                 xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Placeholder: Thumbnail"
                                 preserveAspectRatio="xMidYMid slice" focusable="false"><title>Placeholder</title>
                                <rect width="100%" height="100%" fill="#55595c"/>
                                <text x="50%" y="50%" fill="#eceeef" dy=".3em">Thumbnail</text>
                            </svg>
                            <div class="card-body">
                                <p class="card-text">
                                    <?php
                                    print $liste[$i]->libelle;
                                    ?>
                                </p>
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="btn-group">
                                        <a href="index_.php?id_categorie=<?php print $liste[$i]->id_categorie; ?>&page=produits_categorie_client.php"
                                           type="button" class="btn btn-sm btn-outline-secondary">Voir</a>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>
                    <?php
                }
                ?>
            </div>
        </div>
    </div>

<?php