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
</head>
<body>
<div class="container">
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
    <footer id="footer">&nbsp;

        <div class="footerContacts" id="footerContacts">
            <div class="contactSection1">
                <h3>Contactez-nous</h3>
                <br />
                <ul>
                    <li>+012 34 56 78</li>
                    <li>gerard@entreprise.com</li>
                    <li>Bruxelles/Brussels , BE</li>
                </ul>
            </div>
            <div class="contactSection2">
                <h3>Informations Supplémentaires</h3>
                <br />
                <ul>
                    <li>Voir Aussi</li>
                    <li>Tarification</li>
                    <br />
                </ul>
            </div>
            <div class="contactSection3">
                <h3>Divers</h3>
                <br />
                <ul>
                    <li>Conditions générales d'utilisation</li>
                    <li>Politique de confidentialité</li>
                    <li>FAQ</li>
                </ul>
            </div>
        </div>
    </footer>
</div>
</body>

</html>
