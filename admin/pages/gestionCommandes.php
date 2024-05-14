<?php
// Inclusion des fichiers requis
require './src/php/utils/verifier_connexion.php';

// Vérification des autorisations administratives ici si nécessaire
// Instanciation de la classe CommandeDB pour interagir avec la base de données
$commandeDB = new CommandeDB($cnx);
// Récupération de toutes les commandes avec détails
$listeCommandes = $commandeDB->getToutesLesCommandesAvecDetails();

?>

<div><a href="index_.php?page=disconnect.php">Log out</a></div>
<div>
    <a href="?page=accueil_admin.php">Page Administrateur</a>
    <a href="?page=gestionProduits.php">Gestion des produits</a>
    <a href="?page=gestionCommandes.php">Gestion des commandes</a>

</div>


<div class="container">
    <h1>Liste des Commandes en cours (Administrateur)</h1>
    <?php
    $numCommandePrecedent = null;
    foreach ($listeCommandes as $commande) {
        if ($commande['id_commande'] !== $numCommandePrecedent) {

            if ($numCommandePrecedent !== null) {
                echo "</ul>";
                echo "</li>";
            }
            echo "<li>";
            echo "Commande #" . $commande['id_commande'] . " - Client n° " . $commande['client_id'];
            echo "<ul>";
        }
        echo "<li>Produit : " . $commande['nom_produit']
            . " - Prix unitaire : " . $commande['prix_unitaire'] . " €</li>";
        $numCommandePrecedent = $commande['id_commande'];
    }
    if (!empty($listeCommandes)) {
        echo "</ul>";
        echo "</li>";
    }
    ?>
</div>


