<?php
//toujours vérifier la qualité d'admin
require './src/php/utils/verifier_connexion.php';
$adminData = $_SESSION['admin'];

print "<br>Page d'accueil de l'admin";
?>


<div><a href="index_.php?page=disconnect.php">Log out</a></div>
<div>
    <a href="?page=gestionProduits.php">Gestion des produits</a>
    <a href="?page=gestionCommandes.php">Gestion des commandes</a>

</div>