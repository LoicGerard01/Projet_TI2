<?php

class PanierDB extends Panier
{

    private $_bd;
    private $_array = array();

    public function __construct($cnx)
    {
        $this->_bd = $cnx;
    }

    public function creer_panier($client_id)
    {
        echo $client_id;
        try {
            $query = "select creer_panier(:client_id)";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':client_id', $client_id);
            $res->execute();
            return true; // Retourne vrai si la création du panier réussit
        } catch (PDOException $e) {
            // Afficher l'erreur spécifique en cas d'échec de la requête
            echo "Erreur lors de la création du panier : " . $e->getMessage();
            return false;
        }
    }


    public function ajouter_produit_panier($client_id, $produit_id)
    {
        try {
            $query = "INSERT INTO ti_detailpanier (fk_panier, fk_produit) VALUES ((SELECT id_panier FROM ti_panier WHERE client = :client_id), :produit_id)";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':client_id', $client_id);
            $res->bindValue(':produit_id', $produit_id);
            $res->execute();
            return true; // Succès de l'ajout au panier
        } catch (PDOException $e) {
            echo "Erreur lors de l'ajout au panier : " . $e->getMessage();
            return false; // Échec de l'ajout au panier
        }
    }


    public function hasPanier($client_id)
    {
        try {
            $query = "SELECT COUNT(*) FROM ti_panier WHERE client = :client_id";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':client_id', $client_id);
            $res->execute();
            $count = $res->fetchColumn();
            return $count > 0; // Retourne vrai si le panier existe pour ce client
        } catch (PDOException $e) {
            // Afficher l'erreur spécifique en cas d'échec de la requête
            echo "Erreur lors de la vérification du panier : " . $e->getMessage();
            return false;
        }
    }

    public function produits_dans_panier($client_id)
    {
        try {
            $query = "select * from produits_dans_panier(:client_id)";

            $res = $this->_bd->prepare($query);
            $res->bindValue(':client_id', $client_id);
            $res->execute();

            // Récupérer tous les résultats sous forme de tableau associatif
            $produits = $res->fetchAll(PDO::FETCH_ASSOC);

            return $produits; // Retourner le tableau des produits dans le panier
        } catch (PDOException $e) {
            // Afficher l'erreur spécifique en cas d'échec de la requête
            echo "Erreur lors de la récupération des produits dans le panier : " . $e->getMessage();
            return []; // Retourner un tableau vide en cas d'échec
        }
    }

    public function supprimer_panier($client_id){
        try {
            $query = "select supprimer_panier(:client_id)";

            $res = $this->_bd->prepare($query);
            $res->bindValue(':client_id', $client_id);
            $res->execute();
            echo "produit ajouté";
        } catch (PDOException $e) {
            print "Echec " . $e->getMessage();
        }



    }





}

