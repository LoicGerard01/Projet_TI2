<?php
// Inclusion du fichier verif_client.php avec le chemin correct
if (!isset($_SESSION['client'])) {
    // Redirection vers la page d'accueil si le client n'est pas connecté
    ?>
    <meta http-equiv="refresh" content="0;URL=../index_.php?page=accueil.php">
    <?php
}
?>
