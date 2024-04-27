<?php
header('Content-Type: application/json');
//chemin d'accès depuis le fichier ajax php
// Chemin d'accès depuis le fichier ajax PHP
require '../db/dbPgConnect.php';
require '../classes/Connexion.class.php';
require '../classes/Commande.class.php';
require '../classes/CommandeDB.class.php';

$cnx = Connexion::getInstance($dsn, $user, $password);

$commandeDB = new CommandeDB($cnx);
$data[] = $commandeDB->creer_commande($_GET['panier_id']);
print json_encode($data);



