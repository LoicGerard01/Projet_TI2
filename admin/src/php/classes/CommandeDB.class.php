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
            // Optionnel : retourner l'identifiant de la commande créée
            return $this->_bd->lastInsertId();
        } catch (PDOException $e) {
            print "Echec " . $e->getMessage();
        }
    }

    public function transferer_panier_vers_commande($client_id)
    {
        try {
            $query = "select transferer_panier_vers_commande(:client_id";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':client_id', $client_id);
            $res->execute();
            echo "commande créée";
        } catch (PDOException $e) {
            print "Echec " . $e->getMessage();
        }
    }



}

