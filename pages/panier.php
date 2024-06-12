<?php
// Vérification de l'authentification de l'utilisateur
require 'admin/src/php/utils/verif_client.php';
//print "<br>Page d'accueil du client ";
?>
<div class="liens">
    <a href="index_.php?page=accueil_client.php">Revenir à l'accueil</a>
    <a href="index_.php?page=disconnect.php">Log out</a>

</div>
<br>
<?php



$cat = new CategorieDB($cnx);
$liste = $cat->getAllCategories();
$nbr_cat = count($liste);

$clientDB = new ClientDB($cnx);
$panierDB = new PanierDB($cnx);
$clientId = $_SESSION['client'];
$commandeDB = new CommandeDB($cnx);

$clientInfo = $clientDB->getClientById($clientId);

$id_client = $clientInfo['id_client'];

if ($clientInfo) {
    $nomClient = $clientInfo['prenom'];
    echo "<p>Bonjour $nomClient !</p>";
} else {
    echo "<p>Bonjour !</p>";
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
if (isset($_POST['valider_commande'])) {
    try {
        // Transfère le contenu du panier vers la commande
        $pdo = new PDO('pgsql:host=localhost;dbname=demo;port=5432', 'anonyme', 'anonyme');
        $commandeDB = new CommandeDB($pdo);

        $result = $commandeDB->passer_commande($clientId);


        echo "Commande validée avec succès. Panier vidé.";


        header("Refresh:1000");
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

</nav>

<?php
$produitDB = new ProduitsDB($cnx);
$listeProduits = $panierDB->produits_dans_panier($clientId);

// Affiche les détails des produits dans le panier
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

    // Formulaire pour valider la commande
    echo '<form method="post" action="">';
    echo '<input type="hidden" name="client_id" value="' . $clientId . '">';
    echo '<button type="submit" name="valider_commande" class="btn btn-success">Valider la commande</button>';
    echo '</form>';

}
else echo "<h2>Votre panier est vide </h2>";
?>
