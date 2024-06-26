<?php
session_start();
require './admin/src/php/utils/liste_includes.php';
?>
<!doctype html>
<html lang="fr">
<head>
    <title>Demo 2023-2024</title>
    <meta charset="utf-8">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="admin/public/css/style.css" type="text/css">
    <link rel="stylesheet" href="admin/public/css/custom.css" type="text/css">
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>

</head>
<body>
<div class="page">
    <header id="header">
    </header>

    <nav id="menu">
        <?php
        if (file_exists('./admin/src/php/utils/menu_public.php')) {
            include './admin/src/php/utils/menu_public.php';
        }
        ?>

    </nav>
    <div id="contenu">
        <?php
        //si aucune variable de session 'page'
        if (!isset($_SESSION['page'])) {
            $_SESSION['page'] = './pages/accueil.php';
            ?> <?php
        }
        if (isset($_GET['page'])) {
            //print "<br>paramètre page : ".$_GET['page']."<br>";
            $_SESSION['page'] = 'pages/'.$_GET['page'];

        }
        if (file_exists($_SESSION['page'])) {
            include $_SESSION['page'];

        } else {
            include './pages/page404.php';
        }

        ?>
    </div>
    <div>
        <?php
        if (file_exists('./admin/src/php/utils/footer.php')) {
            include './admin/src/php/utils/footer.php';
        }
        ?>
    </div>
</div>
<script src="./admin/public/js/fonctions.js"></script>
</body>

</html>
