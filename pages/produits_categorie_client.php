<?php

require_once 'admin/src/php/classes/CategorieDB.class.php';
require_once 'admin/src/php/classes/PanierDB.class.php';

// Vérifie si un produit doit être ajouté au panier
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['id_produit'])) {

    $idProduit = $_POST['id_produit'];

    session_start();
    $clientId = $_SESSION['client'];


    $panierDB = new PanierDB($cnx);


    $result = $panierDB->ajouter_produit_panier($clientId, $idProduit);


    if ($result) {
        $reponse = "success";
        echo "success";
    } else {
        $reponse = "error";
        echo "error";
    }

    exit;
}


$cat = new CategorieDB($cnx);
$liste = $cat->getProduitsById_cat($_GET['id_categorie']);
$nbr = count($liste);
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Liste des produits</title>

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

                        <img src="<?php echo $liste[$i]->image; ?>" class="bd-placeholder-img card-img-top" width="100%"
                             height="225" alt="Image produit">

                        <div class="card-body">
                            <p class="card-text"><?php echo $liste[$i]->nom; ?></p>
                            <p class="card-text"><?php echo $liste[$i]->description; ?></p>
                            <p class="card-text"><?php echo $liste[$i]->prix; ?>€</p>
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="btn-group">

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

</body>
</html>
