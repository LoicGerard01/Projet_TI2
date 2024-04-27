<?php
header('Content-Type: application/json');
//chemin d'accès depuis le fichier ajax php
require '../db/dbPgConnect.php';
require '../classes/Connexion.class.php';
require '../classes/Produit.class.php';
require '../classes/ProduitDB.class.php';

$cnx = Connexion::getInstance($dsn, $user, $password);

$produitDB = new ProduitDB($cnx);
$data[] = $produitDB->ajout_produit($_GET['nom'], $_GET['description'], $_GET['prix'], $_GET['categorie']);
print json_encode($data);

