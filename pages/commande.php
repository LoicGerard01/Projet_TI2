<?php
// Inclusion des fichiers requis
require 'admin/src/php/utils/verif_client.php'; // Vérification de l'authentification
require 'vendor/autoload.php';
?>
<div class="liens">
    <a href="index_.php?page=accueil_client.php">Revenir à l'accueil</a>
    <a href="index_.php?page=disconnect.php">Log out</a>
</div><br>

<?php
use Com\Tecnick\Pdf\Tcpdf;

// Créer une nouvelle instance de TCPDF
$pdf = new Tcpdf('mm', true, true, true, 'pdfa1', null);

$pdf->SetCreator("GG Entreprise");
$pdf->SetAuthor('GG Entreprise');
$pdf->SetTitle('Historique des Commandes');
$pdf->SetSubject('Historique des Commandes');
$pdf->SetKeywords('Commandes, PDF, Historique');
$pdf->setDefaultCellMargin(15,15,15,15);

$html = '<h2>Historique des commandes</h2>';

// Instanciation de la classe CommandeDB
$commandeDB = new CommandeDB($cnx);

// Récupération de l'identifiant du client à partir de la session
$client_id = $_SESSION['client'];

// Récupération des commandes du client
$listeCommandes = $commandeDB->get_commandes_client($client_id);

?>
<nav id="menu">
    <?php
    if (file_exists('./src/php/utils/menu_public.php')) {
        include './src/php/utils/menu_public.php';
    }
    ?>

</nav>

<div class="container">
    <h2>Historique des Commandes</h2>
    <?php
    // Vérifier s'il y a des commandes à afficher
    if ($listeCommandes && !empty($listeCommandes)) {
        // Initialiser un tableau pour stocker les commandes avec leurs produits
        $commandesAvecProduits = array();

        // Boucler sur chaque commande pour regrouper les produits par commande
        foreach ($listeCommandes as $commande) {
            $idCommande = $commande['id_commande'];
            // Vérifier si la commande existe déjà dans le tableau
            if (!isset($commandesAvecProduits[$idCommande])) {
                // Si la commande n'existe pas, l'ajouter avec son détail
                $commandesAvecProduits[$idCommande] = array(
                    'id_commande' => $commande['id_commande'],
                    'date_commande' => $commande['date_commande'],
                    'statut_commande' => $commande['statut_commande'],
                    'produits' => array() // Initialiser un tableau vide pour les produits
                );
            }

            // Ajouter le produit à la commande correspondante
            $commandesAvecProduits[$idCommande]['produits'][] = array(
                'id_produit' => $commande['id_produit'],
                'nom_produit' => $commande['nom_produit'],
                'description_produit' => $commande['description_produit'],
                'prix_produit' => $commande['prix_produit']
            );
        }

        // Afficher les commandes avec leurs produits
        echo "<ul>";
        foreach ($commandesAvecProduits as $commande) {
            echo "<li>";
            echo "Commande #" . $commande['id_commande'] . " - Date : " . $commande['date_commande'] . " - Statut : " . $commande['statut_commande'];

            // Afficher les produits de la commande
            echo "<ul>";
            $totalCommande = 0;
            foreach ($commande['produits'] as $produit) {
                echo "<li>Produit : " . $produit['nom_produit'] . " - Prix : " . $produit['prix_produit'] . " €</li>";
                $totalCommande += $produit['prix_produit'];
            }
            echo "</ul>";

            // Afficher le prix total de la commande
            echo "<p>Total de la commande : " . $totalCommande . " €</p>";

            echo "</li>";
        }
        echo "</ul>";
    } else {
        echo "<p>Aucune commande trouvée pour ce client.</p>";
    }

    ?>
</div>
