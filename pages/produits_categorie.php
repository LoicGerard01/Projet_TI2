<?php
$cat = new CategorieDB($cnx);
$liste = $cat->getProduitsById_cat($_GET['id_categorie']);
$nbr = count($liste);
?>

<a href="?page=accueil.php">Page précédente</a>
<div class="album py-5 bg-body-tertiary">
    <div class="container">
        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3">
            <?php

            for ($i = 0; $i < $nbr; $i++) {
                $produit = $liste[$i];

                ?>
                <div class="col">
                    <div class="card shadow-sm">
                        <!-- Remplacez cette partie par l'affichage de l'image -->
                        <?php if (empty($produit->image)) { ?>
                            <img src="<?php echo $produit->image; ?>" class="bd-placeholder-img card-img-top"
                                 width="100%" height="225" alt="Image produit">
                        <?php } ?>

                        <div class="card-body">
                            <p class="card-text">
                                <?php echo $produit->description; ?>
                            </p>
                            <div class="d-flex justify-content-between align-items-center">
                                <!-- Vous pouvez ajouter d'autres éléments ici -->
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
