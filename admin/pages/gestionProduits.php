<?php
require './src/php/utils/verifier_connexion.php';
require_once './src/php/db/dbPgConnect.php';
require_once './src/php/classes/Connexion.class.php';
require_once './src/php/classes/CommandeDB.class.php';

?>

<div><a href="index_.php?page=disconnect.php">Log out</a></div>
<div>
    <a href="?page=accueil_admin.php">Page Administrateur</a>
    <a href="?page=gestionProduits.php">Gestion des produits</a>
    <a href="?page=gestionCommandes.php">Gestion des commandes</a>

</div>
