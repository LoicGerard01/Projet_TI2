<?php

class CommandeDB extends Commande
{

    private $_bd;
    private $_array = array();

    public function __construct($cnx)
    {
        $this->_bd = $cnx;
    }

    public function creer_commande($panier_id)
    {
        try {
            $query = "INSERT INTO commande (fk_panier) VALUES (:panier_id)";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':panier_id', $panier_id);
            $res->execute();

            return $this->_bd->lastInsertId();
        } catch (PDOException $e) {
            print "Echec " . $e->getMessage();
        }
    }

    public function passer_commande($client_id)
    {
        try {
            $query = "SELECT passer_commande(:client_id)";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':client_id', $client_id);
            $res->execute();
            //echo "Commande validée avec succès. Panier vidé.";
        } catch (PDOException $e) {
            echo "Erreur lors de la validation de la commande : " . $e->getMessage();
        }
    }

    public function get_commandes_client($client_id)
    {
        try {
            $query = "SELECT * FROM get_commandes_client(:client_id)";
            $stmt = $this->_bd->prepare($query);
            $stmt->bindValue(':client_id', $client_id, PDO::PARAM_INT);
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            echo "Erreur lors de la récupération des commandes : " . $e->getMessage();
            return null;
        }
    }
    public function getToutesLesCommandesAvecDetails(){
        try{
            $query = "SELECT * FROM vue_commandes_details";
            $res=$this->_bd->prepare($query);
            $res->execute();
            return $res->fetchAll(PDO::FETCH_ASSOC);
        }catch (PDOException $e){
            echo "Erreur ".$e->getMessage();
            return null;
        }
    }





}

