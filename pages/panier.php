<?php
// Vérification de l'authentification de l'utilisateur
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
    $nomClient = $clientInfo['prenom']; // Récupérer le prénom du client depuis les informations récupérées
    echo "<p>Bonjour $nomClient !</p>"; // Afficher un message de bienvenue avec le prénom du client
} else {
    echo "<p>Bonjour !</p>"; // Afficher un message de bienvenue générique
}

if (!$panierDB->hasPanier($clientId)) {
    // Si le client n'a pas de panier, créer un nouveau panier pour ce client
    //echo "Ce client n'a pas de panier.<br>";
    $pdo = new PDO('pgsql:host=localhost;dbname=demo;port=5432', 'anonyme', 'anonyme');
    $panierDB = new PanierDB($pdo);
    $result = $panierDB->creer_panier($clientId);
}
if (isset($_POST['supprimer_panier'])) {
    try {
        $pdo = new PDO('pgsql:host=localhost;dbname=demo;port=5432', 'anonyme', 'anonyme');
        $panierDB = new PanierDB($pdo);

        $result = $panierDB->supprimer_panier($clientId);

        if ($result) {
            echo "Panier vidé avec succès.";
        } else {
            echo "Échec de la suppression du panier.";
        }
    } catch (PDOException $e) {
        echo "Erreur PDO : " . $e->getMessage();
    }
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

// Afficher les détails des produits dans le panier
if ($listeProduits && !empty($listeProduits)) {
    echo "<h3>Produits dans votre panier :</h3>";
    echo "<ul>";

    foreach ($listeProduits as $produit) {
        echo "<li>{$produit['product_name']} - Prix : {$produit['product_price']} €</li>";
    }

    echo "</ul>";

    // Formulaire pour supprimer le contenu du panier sur la même page
    echo '<form method="post" action="">';
    echo '<input type="hidden" name="client_id" value="' . $clientId . '">';
    echo '<button type="submit" name="supprimer_panier" class="btn btn-danger">Vider le panier</button>';
    echo '</form>';
}
else echo "<h2>Votre panier est vide </h2>";
?>
