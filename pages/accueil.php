<?php
$cat = new CategorieDB($cnx);
$liste = $cat->getAllCategories();
$nbr_cat = count($liste);

?>


<div class="liens">
    <a href="index_.php?page=login.php">Connexion</a>
    <a href="index_.php?page=creationCompte.php">Créer Son Compte</a>
</div>

<div class="contenu">

    <div id="carouselExampleIndicators" class="carousel slide" data-ride="carousel">
        <ol class="carousel-indicators">
            <li data-target="#carouselExampleIndicators" data-slide-to="0" class="active"></li>
            <li data-target="#carouselExampleIndicators" data-slide-to="1"></li>
            <li data-target="#carouselExampleIndicators" data-slide-to="2"></li>
        </ol>
        <div class="carousel-inner">
            <div class="carousel-item active">
                <img src="../admin/public/images/986_AMD-CPU-program_Stage_dFr.webp" class="d-block w-100" alt="Image 1">
            </div>
            <div class="carousel-item">
                <img src="../admin/public/images/986_Hyte-Y70-Touch_Stage_dFr.webp" class="d-block w-100" alt="Image 2">
            </div>
            <div class="carousel-item">
                <img src="../admin/public/images/1242_Korting-Gamer-Red_Stage_d-FR.webp" class="d-block w-100" alt="Image 3">
            </div>
        </div>
        <a class="carousel-control-prev" href="#carouselExampleIndicators" role="button" data-slide="prev">
            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
            <span class="sr-only">Previous</span>
        </a>
        <a class="carousel-control-next" href="#carouselExampleIndicators" role="button" data-slide="next">
            <span class="carousel-control-next-icon" aria-hidden="true"></span>
            <span class="sr-only">Next</span>
        </a>
    </div>


    <div class="p-3 mb-2 bg-body-tertiary border">
        <div class="container">
            <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3">
                <?php
                for ($i = 0; $i < $nbr_cat; $i++) {
                    ?>
                    <div class="col">
                        <div class="card shadow-sm">

                            <img src="./admin/public/images/<?php echo($i + 1); ?>.jpg"
                                 class="bd-placeholder-img card-img-top img-fluid" alt="Image de la catégorie">

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
</div>