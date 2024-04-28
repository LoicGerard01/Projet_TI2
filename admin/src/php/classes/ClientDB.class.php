<?php

class ClientDB extends Client
{

    private $_bd;
    private $_array = array();

    public function __construct($cnx)
    {
        $this->_bd = $cnx;
    }

    public function ajout_client($nom,$prenom,$email,$adresse,$numero,$password){
        try{
            $query = "SELECT ajout_client(:nom, :prenom, :email, :adresse, :numero, :password)";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':nom',$nom);
            $res->bindValue(':prenom',$prenom);
            $res->bindValue(':email',$email);
            $res->bindValue(':adresse',$adresse);
            $res->bindValue(':numero',$numero);
            $res->bindValue(':password',$password);
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

    public function verif_client($email,$password){
        try {
            $query = "SELECT id_client FROM ti_client WHERE email = :email AND password = :password";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':email', $email);
            $res->bindValue(':password', $password);
            $res->execute();
            $result = $res->fetch(PDO::FETCH_ASSOC);
            return $result ? true : false;

        }catch (PDOException $e){
            print "Echec ".$e->getMessage();
        }


    }




}

