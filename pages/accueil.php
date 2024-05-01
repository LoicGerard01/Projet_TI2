<?php
$cat = new CategorieDB($cnx);
$liste = $cat->getAllCategories();
$nbr_cat = count($liste);

?>
<a href="index_.php?page=login.php">Connexion</a>
<a href="index_.php?page=creationCompte.php">Creer Son Compte</a>

<div class="album py-5 bg-body-tertiary">
    <div class="container">
        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3">
            <?php
            for ($i = 0; $i < $nbr_cat; $i++) {
                ?>
                <div class="col">
                    <div class="card shadow-sm">
                        <img src="./admin/public/images/<?php echo ($i + 1); ?>.jpg" class="bd-placeholder-img card-img-top" width="100%" height="225" alt="Image de la catégorie">

                        <div class="card-body">
                            <p class="card-text">
                                <?php
                                print $liste[$i]->libelle;
                                ?>
                            </p>
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="btn-group">
                                    <a href="index_.php?id_categorie=<?php print $liste[$i]->id_categorie; ?>&page=produits_categorie.php"
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