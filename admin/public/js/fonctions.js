

    function ajouterAuPanier(idProduit) {
    // Créer une requête AJAX
    let xhr = new XMLHttpRequest();
    xhr.open("POST", "", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function () {
    if (xhr.readyState === 4 && xhr.status === 200) {

    let response = xhr.responseText;
    alert("Produit ajouté au panier !");

}
};

    xhr.send("id_produit=" + idProduit);
}
