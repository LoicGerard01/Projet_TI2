<?php
require './src/php/utils/verifier_connexion.php';
require_once './src/php/db/dbPgConnect.php';
require_once './src/php/classes/Connexion.class.php';
require_once './src/php/classes/CommandeDB.class.php';
require_once './src/php/classes/CategorieDB.class.php';


$cat = new CategorieDB($cnx);
$liste = $cat->getAllCategories();

$nbr_cat = count($liste);


if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $pdo = new PDO('pgsql:host=localhost;dbname=demo;port=5432', 'anonyme', 'anonyme');
    $produitDB = new ProduitsDB($pdo);
    //var_dump($_POST);
    $nom = $_POST['nomProduit'];
    $description = $_POST['descriptionProduit'];
    $prix = $_POST['prixProduit'];
    $id_categorie = $_POST['categorieProduit'];

    $produitDB->ajout_produit($nom,$description,$prix,$id_categorie);
    $_POST = NULL;
    header(0);
}

?>

<div><a href="index_.php?page=disconnect.php">Log out</a></div>
<div>
    <a href="?page=accueil_admin.php">Page Administrateur</a>
    <a href="?page=gestionProduits.php">Gestion des produits</a>
    <a href="?page=gestionCommandes.php">Gestion des commandes</a>

</div>

<div class="album py-5 bg-body-tertiary">
    <div class="container">
        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3">
            <div class="col">
                <h1>Ajouter un Produit</h1>
                <form action="<?php echo htmlspecialchars($_SERVER['PHP_SELF']); ?>" method="post">
                    <div class="mb-3">
                        <label for="nomProduit" class="form-label">Nom du Produit</label>
                        <input type="text" class="form-control" id="nomProduit" name="nomProduit" required>
                    </div>
                    <div class="mb-3">
                        <label for="descriptionProduit" class="form-label">Description</label>
                        <input type="text" class="form-control" id="descriptionProduit" name="descriptionProduit" required>
                    </div>
                    <div class="mb-3">
                        <label for="prixProduit" class="form-label">Prix (€)</label>
                        <input type="number" step="0.01" class="form-control" id="prixProduit" name="prixProduit" required>
                    </div>
                    <div class="mb-3">
                        <label for="categorieProduit" class="form-label">Catégorie</label>
                        <select class="form-select" id="categorieProduit" name="categorieProduit" required>
                            <option value="" disabled selected>Choisir une catégorie</option>
                            <?php foreach ($liste as $categorie) : ?>
                                <option value="<?php echo $categorie->id_categorie; ?>">
                                    <?php echo $categorie->libelle; ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary">Ajouter</button>
                </form>
            </div>
        </div>
    </div>
</div>


<div class="album py-5 bg-body-tertiary">
    <div class="container">
        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3">
            <?php
            for ($i = 0; $i < $nbr_cat; $i++) {
                ?>
                <div class="col">
                    <div class="card shadow-sm">
                        <svg class="bd-placeholder-img card-img-top" width="100%" height="225"
                             xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Placeholder: Thumbnail"
                             preserveAspectRatio="xMidYMid slice" focusable="false"><title>Placeholder</title>
                            <rect width="100%" height="100%" fill="#55595c"/>
                            <text x="50%" y="50%" fill="#eceeef" dy=".3em">Thumbnail</text>
                        </svg>
                        <div class="card-body">
                            <p class="card-text">
                                <?php
                                print $liste[$i]->libelle;
                                ?>
                            </p>
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="btn-group">
                                    <a href="index_.php?id_categorie=<?php print $liste[$i]->id_categorie; ?>&page=produits_categorie_admin.php"
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
