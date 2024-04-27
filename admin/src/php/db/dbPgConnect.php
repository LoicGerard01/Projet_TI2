<?php
$dsn = 'pgsql:host=localhost;dbname=demo;port=5432';
$user = 'anonyme';
$password = 'anonyme';


try {
    $pdo = new PDO($dsn, $user, $password);
    echo "Connexion réussie à PostgreSQL!";
} catch (PDOException $e) {
    echo "Erreur de connexion à PostgreSQL: " . $e->getMessage();
}