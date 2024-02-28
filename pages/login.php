<?php
if (isset($_POST['submit_login'])) { //name du submit
    extract($_POST,EXTR_OVERWRITE);
    //var_dump($_POST);
    $ad = new AdminDB($cnx);
    $admin = $ad->getAdmin($login,$password);//$admin reçoit 1 ou 0
    if($admin){
        //créer variable de session pour admin
        $_SESSION['admin']=1; //sera vérifiée dans toutes les pages admin
        ////rediriger vers dossier admin
        ?>
        <meta http-equiv="refresh" content="0;URL=admin/index_.php?page=accueil_admin.php">
        <?php

    }else {
        //rediriger vers accueil public
        print "<br>Accès réservé aux administrateurs";
        ?>
        <meta http-equiv="refresh" content="3;URL=index_.php?page=accueil.php">
        <?php
    }
}
?>
<!-- formulaire de cnx ici -->

<form method="post" action="<?= $_SERVER['PHP_SELF'];?>">
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