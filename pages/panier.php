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

if (!$panierDB->hasPanier($clientId)) {
    // Si le client n'a pas de panier, créer un nouveau panier pour ce client
    $panier_id = $panierDB->creer_panier($clientId); // Créer un nouveau panier et récupérer son ID
}

?>
    <nav id="menu">
        <?php
        if (file_exists('./src/php/utils/menu_public.php')) {
            include './src/php/utils/menu_public.php';
        }
        ?>

        <a href="index_.php?page=disconnect.php">Log out</a>
        <a href="index_.php?page=accueil_client.php">Revenir à l'accueil</a>

    </nav>