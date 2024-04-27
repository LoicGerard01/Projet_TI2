<?php
header('Content-Type: application/json');
//chemin d'accès depuis le fichier ajax php
require '../db/dbPgConnect.php';
require '../classes/Connexion.class.php';
require '../classes/Panier.class.php';
require '../classes/PanierDB.class.php';

$cnx = Connexion::getInstance($dsn, $user, $password);

$panierDB = new PanierDB($cnx);
$data[] = $panierDB->creer_panier($_GET['client_id']);
print json_encode($data);


