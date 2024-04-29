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

$id_client = $clientInfo['id_client'];

if ($clientInfo) {
    $nomClient = $clientInfo['prenom']; // Récupérer le nom du client depuis les informations récupérées
    echo "<p>Bonjour $nomClient !</p>"; // Afficher un message de bienvenue avec le nom du client

} else {
    echo "<p>Bonjour !</p>"; // Afficher un message de bienvenue générique
}

if (!$panierDB->hasPanier($clientId)) {
    // Si le client n'a pas de panier, créer un nouveau panier pour ce client
    echo "Ce client n'a pas de panier.<br>";
    $pdo = new PDO('pgsql:host=localhost;dbname=demo;port=5432', 'anonyme', 'anonyme');
    $panierDB = new PanierDB($pdo);
    $result = $panierDB->creer_panier($clientId);
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

<?php
$produitDB = new ProduitsDB($cnx);
$listeProduits = $panierDB->produits_dans_panier($clientId);
//var_dump($listeProduits);

// Afficher les détails des produits dans le panier
if ($listeProduits && !empty($listeProduits)) {
    echo "<h3>Produits dans votre panier :</h3>";
    echo "<ul>";
    foreach ($listeProduits as $produit) {
        echo "<li>{$produit['product_name']} 
- Prix : {$produit['product_price']} €</li>";
    }
    echo "</ul>";
} else {
    echo "<p>Votre panier est vide.</p>";
}
?>


