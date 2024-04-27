<?php
header('Content-Type: application/json');
//chemin d'accès depuis le fichier ajax php
// Chemin d'accès depuis le fichier ajax PHP
require '../db/dbPgConnect.php';
require '../classes/Connexion.class.php';
require '../classes/Panier.class.php';
require '../classes/PanierDB.class.php';

$cnx = Connexion::getInstance($dsn, $user, $password);

$panierDB = new PanierDB($cnx);
$data[] = $panierDB->ajout_produit_panier($_GET['client_id'],$_GET['produit_id']);
print json_encode($data);




