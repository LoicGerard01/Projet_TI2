<?php
// Inclure les classes et la connexion à la base de données
require_once 'admin/src/php/db/dbPgConnect.php';
require_once 'admin/src/php/classes/Connexion.class.php';
require_once 'admin/src/php/classes/ClientDB.class.php';
require_once 'admin/src/php/classes/PanierDB.class.php';
// Variables pour stocker les données du formulaire et les messages d'erreur
$nom = $prenom = $email = $adresse = $numero = '';
$successMessage = $errorMessage = '';

// Vérifier si le formulaire a été soumis
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Récupérer les données du formulaire
    $nom = $_POST['nom'];
    $prenom = $_POST['prenom'];
    $email = $_POST['email'];
    $adresse = $_POST['adresse'];
    $numero = $_POST['numero'];

    // Valider les données (vous pouvez ajouter des validations supplémentaires ici)

    // Créer une instance de ClientDB en passant la connexion PDO
    $pdo = new PDO('pgsql:host=localhost;dbname=demo;port=5432', 'anonyme', 'anonyme');
    $clientDB = new ClientDB($pdo);

    // Appeler la méthode ajout_client pour insérer le nouveau client
    $result = $clientDB->ajout_client($nom, $prenom, $email, $adresse, $numero);
    if ($result) {
        $successMessage = "Compte crée avec succès";
        // Réinitialiser les champs du formulaire après un ajout réussi
        $nom = $prenom = $email = $adresse = $numero = '';
    } else {
        $errorMessage = "Erreur lors de la creation du compte.";
    }


}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Ajouter un nouveau client</title>
</head>
<body>
<h2>Formulaire d'ajout de client</h2>

<?php if (!empty($successMessage)) : ?>
    <p style="color: green;"><?php echo $successMessage; ?></p>
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

    <input type="submit" value="Ajouter">
</form>
</body>
</html>
