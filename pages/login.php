<?php

if (isset($_POST['submit_login'])) {
    // Extraction des données du formulaire
    extract($_POST, EXTR_OVERWRITE);

    // Connexion à la base de données
    $connexion = Connexion::getInstance($dsn, $user, $password);

    // Création des instances des classes AdminDB et ClientDB
    $adminDB = new AdminDB($connexion);
    $clientDB = new ClientDB($connexion);

    // Vérification si les identifiants appartiennent à un administrateur
    $admin = $adminDB->getAdmin($login, $password);

    if ($admin) {
        // Identifiant de session pour les administrateurs
        $_SESSION['admin'] = 1;
        // Redirection vers l'espace administrateur
        header("Location: admin/index_.php?page=accueil_admin.php");
        exit;
    } else {
        // Vérification si les identifiants appartiennent à un client
        $email = $login;
        $client = $clientDB->verif_client($email, $password);

        if ($client) {
            // Identifiant de session pour les clients
            $_SESSION['client'] = true;
            // Redirection vers l'espace client
            header("Location: index_.php?page=accueil_client.php");
            exit;
        } else {
            // Si ni admin ni client, afficher un message d'erreur
            echo "<br>Erreur de login et/ou de mot de passe.";
            ?>
            <meta http-equiv="refresh" content="4;URL=index_.php?page=accueil.php">
            <?php
        }
    }
}
?>
<!-- formulaire de cnx ici -->
<h2> Connexion </h2><br>
<form method="post" action="<?= $_SERVER['PHP_SELF']; ?>">
    <div class="mb-3">
        <label for="login" class="form-label">Email address</label>
        <input type="text" name="login" class="form-control" id="login" aria-describedby="loginHelp">
    </div>
    <div class="mb-3">
        <label for="password" class="form-label">Password</label>
        <input type="password" name="password" class="form-control" id="password">
    </div>
    <button type="submit" name="submit_login" class="btn btn-primary">Connexion</button>
</form>