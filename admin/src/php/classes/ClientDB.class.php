<?php

class ClientDB extends Client
{

    private $_bd;
    private $_array = array();

    public function __construct($cnx)
    {
        $this->_bd = $cnx;
    }

    public function ajout_client($nom,$prenom,$email,$adresse,$numero){
        try{
            $query = "SELECT ajout_client(:nom, :prenom, :email, :adresse, :numero)";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':nom',$nom);
            $res->bindValue(':prenom',$prenom);
            $res->bindValue(':email',$email);
            $res->bindValue(':adresse',$adresse);
            $res->bindValue(':numero',$numero);
            $res->execute();
            $data = $res->fetch();
            return $data;
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            if ($result) {
                echo "Client ajouté avec succès. Identifiant du client : " . $result['client_id'];
            } else {
                echo "Erreur lors de l'ajout du client.";
            }
        }catch(PDOException $e){
            print "Echec ".$e->getMessage();
        }
    }


    public function getClientByEmail($email){
        try{
            $query="select * from ti_client where email = :email";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':email',$email);
            $res->execute();
            $data = $res->fetch();
            return $data;
        }catch(PDOException $e){
            print "Echec ".$e->getMessage();
        }
    }


}

