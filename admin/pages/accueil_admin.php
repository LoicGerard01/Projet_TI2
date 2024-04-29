<?php
//toujours vérifier la qualité d'admin
require 'src/php/utils/verifier_connexion.php';

$adminData = $_SESSION['admin'];

print "<br>Page d'accueil de l'admin";
