<?php
// Inclure les classes et initialisations nécessaires
require_once 'admin/src/php/classes/CategorieDB.class.php';
require_once 'admin/src/php/classes/PanierDB.class.php';

// Vérifier si un produit doit être ajouté au panier
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['id_produit'])) {
    // Récupérer l'identifiant du produit à ajouter
    $idProduit = $_POST['id_produit'];

    // Démarrer la session pour accéder à $_SESSION['client']
    session_start();
    $clientId = $_SESSION['client'];

    // Créer une instance de la classe PanierDB
    $panierDB = new PanierDB($cnx);

    // Appeler la méthode pour ajouter le produit au panier
    $result = $panierDB->ajouter_produit_panier($clientId, $idProduit);

    // Envoyer une réponse au client en fonction du résultat
    if ($result) {
        $reponse = "success";
        echo "success";
    } else {
        $reponse = "error";
        echo "error";
    }

    exit; // Arrêter le script PHP après la réponse AJAX
}

// Récupérer la liste des produits de la catégorie spécifiée
$cat = new CategorieDB($cnx);
$liste = $cat->getProduitsById_cat($_GET['id_categorie']);
$nbr = count($liste);
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Liste des produits</title>
    <!-- Ajoutez ici vos liens CSS et scripts JavaScript si nécessaire -->
</head>
<body>
<a href="index_.php?page=disconnect.php">Log out</a>
<a href="?page=panier.php">Consulter votre panier</a>
<a href="?page=accueil_client.php">Page précédente</a>

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
                                    <button type="button" class="btn btn-sm btn-outline-secondary"
                                            onclick="ajouterAuPanier(<?php echo $liste[$i]->id_produit; ?>)">Ajouter au
                                        panier
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            <?php endfor; ?>
        </div>
    </div>
</div>

<script>
    // Fonction JavaScript pour ajouter un produit au panier via AJAX
    function ajouterAuPanier(idProduit) {
        // Créer une requête AJAX
        let xhr = new XMLHttpRequest();
        xhr.open("POST", "", true); // Utilisez la même page comme point de destination pour la requête AJAX
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                // Gérer la réponse du serveur
                let response = xhr.responseText;
                alert("Produit ajouté au panier !");

            }
        };

        // Envoyer les données POST avec l'identifiant du produit
        xhr.send("id_produit=" + idProduit);
    }
</script>

</body>
</html>
