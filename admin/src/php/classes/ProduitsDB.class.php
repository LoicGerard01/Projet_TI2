<?php

class ProduitsDB extends Produits
{

    private $_bd;
    private $_array = array();

    public function __construct($cnx)
    {
        $this->_bd = $cnx;
    }
    public function ajout_produit($nom, $description, $prix, $categorie)
    {
        try {
            $query = "select ajout_produit(:nom,:description,:prix,:categorie)";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':nom', $nom);
            $res->bindValue(':description', $description);
            $res->bindValue(':prix', $prix);
            $res->bindValue(':categorie', $categorie);
            $res->execute();
            // Optionnel : retourner l'identifiant du produit inséré
            return $this->_bd->lastInsertId();
        } catch (PDOException $e) {
            print "Echec " . $e->getMessage();
        }
    }
    public function supprimer_produit($id_produit)
    {
        try {
            $query = "select supprimer_produit(:id_produit)";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':id_produit', $id_produit);
            $res->execute();
            // Optionnel : retourner l'identifiant du produit inséré
            return $this->_bd->lastInsertId();
        } catch (PDOException $e) {
            print "Echec " . $e->getMessage();
        }
    }

    public function getProduitById($id_produit){
        try{
            $query="select from produits where id_produit = :id_produit";
            $res = $this->_bd->prepare($query);
            $res->bindValue(':id_produit',$id_produit);
            $res->execute();
            $data = $res->fetch();
            return $data;
        }catch(PDOException $e){
            print "Echec ".$e->getMessage();
        }
    }




}

