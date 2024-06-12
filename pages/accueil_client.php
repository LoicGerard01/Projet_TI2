<?php
//toujours vérifier la qualité d'admin
require 'admin/src/php/utils/verif_client.php';
// print "<br>Page d'accueil du client ";


$cat = new CategorieDB($cnx);
$liste = $cat->getAllCategories();
$nbr_cat = count($liste);

$clientDB = new ClientDB($cnx);
$panierDB = new PanierDB($cnx);
$clientId = $_SESSION['client'];

$clientInfo = $clientDB->getClientById($clientId);

?>
    <nav id="menu">
        <?php
        if (file_exists('./src/php/utils/menu_public.php')) {
            include './src/php/utils/menu_public.php';
        }
        ?>
    <div class="liens">
        <a href="?page=panier.php">Consulter votre panier</a>
        <a href="?page=commande.php">Afficher l'historique des commandes</a>
        <a href="index_.php?page=disconnect.php">Log out</a>
    </div>
    </nav>
<?php
if ($clientInfo) {
    $nomClient = $clientInfo['nom'];
    echo "<br><p>Bonjour $nomClient !</p>";
} else {
    echo "<p>Bonjour !</p>";
}


?>

    <div class="contenu">
        <div class="p-3 mb-2 bg-body-tertiary border">
            <div class="container">
                <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3">
                    <?php
                    for ($i = 0; $i < $nbr_cat; $i++) {
                        ?>
                        <div class="col">
                            <div class="card shadow-sm">
                                <img src="./admin/public/images/<?php echo($i + 1); ?>.jpg"
                                     class="bd-placeholder-img card-img-top" width="100%" height="225"
                                     alt="Image de la catégorie">

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
    </div>

<?php