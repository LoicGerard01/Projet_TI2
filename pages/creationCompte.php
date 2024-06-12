<?php

// Variables pour stocker les données du formulaire et les messages d'erreur
$nom = $prenom = $email = $adresse = $numero = $password = '';
$successMessage = $errorMessage = '';

// Vérifier si le formulaire a été soumis
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Récupérer les données du formulaire
    $nom = $_POST['nom'];
    $prenom = $_POST['prenom'];
    $email = $_POST['email'];
    $adresse = $_POST['adresse'];
    $numero = $_POST['numero'];
    $password = $_POST['password'];

    $pdo = new PDO('pgsql:host=localhost;dbname=demo;port=5432', 'anonyme', 'anonyme');
    $clientDB = new ClientDB($pdo);

    $result = $clientDB->ajout_client($nom, $prenom, $email, $adresse, $numero , $password);
    if ($result) {
        $successMessage = "Compte crée avec succès";
        $nom = $prenom = $email = $adresse = $numero = $password = '';
    } else {
        $errorMessage = "Erreur lors de la creation du compte.";
    }


}
?>

<title>Ajouter un nouveau client</title>

<h2>Formulaire de création de compte</h2>
<br>
<?php if (!empty($successMessage)) : ?>
    <p style="color: green;"><?php echo $successMessage; ?></p>
    <meta http-equiv="refresh" content="4;URL=index_.php?page=accueil.php">
<?php endif; ?>

<?php if (!empty($errorMessage)) : ?>
    <p style="color: red;"><?php echo $errorMessage; ?></p>
<?php endif; ?>

<form method="post" action="<?php echo htmlspecialchars($_SERVER['PHP_SELF']); ?>">
    <label for="nom">Nom :</label>
    <input type="text" id="nom" name="nom" value="<?php echo htmlspecialchars($nom); ?>" required><br><br>

    <label for="prenom">Prénom :</label>
    <input type="text" id="prenom" name="prenom" value="<?php echo htmlspecialchars($prenom); ?>" required><br><br>

    <label for="email">Email :</label>
    <input type="email" id="email" name="email" value="<?php echo htmlspecialchars($email); ?>" required><br><br>

    <label for="adresse">Adresse :</label>
    <input type="text" id="adresse" name="adresse" value="<?php echo htmlspecialchars($adresse); ?>" required><br><br>

    <label for="numero">Numéro de téléphone :</label>
    <input type="text" id="numero" name="numero" value="<?php echo htmlspecialchars($numero); ?>" required><br><br>

    <label for="password">Mot de passe :</label>
    <input type="password" id="password" name="password" value="<?php echo htmlspecialchars($password); ?>" required><br><br>

    <input type="submit" value="Ajouter">
</form>

