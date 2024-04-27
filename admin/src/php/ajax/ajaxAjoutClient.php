<?php
header('Content-Type: application/json');
//chemin d'accès depuis le fichier ajax php
require '../db/dbPgConnect.php';
require '../classes/Connexion.class.php';
require '../classes/Client.class.php';
require '../classes/ClientDB.class.php';
$cnx = Connexion::getInstance($dsn,$user,$password);

$cl = new ClientDB($cnx);
$data[] = $cl->ajout_client($_GET['nom'],$_GET['prenom'],$_GET['email'],$_GET['adresse'],$_GET['numero']);
print json_encode($data);


