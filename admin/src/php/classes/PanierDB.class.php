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
        try {
            $query = "INSERT INTO ti_panier (client) VALUES (:client_id)";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':client_id', $client_id);
            $res->execute();

            // Optionnel : retourner l'identifiant du panier créé
            return $this->_bd->lastInsertId();
        } catch (PDOException $e) {
            print "Echec " . $e->getMessage();
        }
    }

    public function ajout_produit_panier($client_id, $produit_id)
    {
        try {
            $query = "INSERT INTO ti_detailpanier (fk_panier, fk_produit) VALUES ((SELECT id_panier FROM ti_panier WHERE client = :client_id), :produit_id)";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':client_id', $client_id);
            $res->bindValue(':produit_id', $produit_id);
            $res->execute();
            echo "Produit ajouté au panier avec succès.";
        } catch (PDOException $e) {
            print "Echec " . $e->getMessage();
        }
    }

    public function hasPanier($clientId)
    {
        try {
            $query = "SELECT COUNT(*) FROM ti_panier WHERE client = :client_id";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':client_id', $clientId);
            $res->execute();
            $count = $res->fetchColumn();
            return $count > 0;
        } catch (PDOException $e) {
            print "Echec " . $e->getMessage();
        }
    }




}

