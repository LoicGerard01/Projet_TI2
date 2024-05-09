--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

-- Started on 2024-05-09 10:02:26

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 24578)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- TOC entry 5063 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 255 (class 1255 OID 24579)
-- Name: ajout_admin(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ajout_admin(p_login text, p_password text) RETURNS integer
    LANGUAGE plpgsql
    AS '
DECLARE
  id INTEGER;
  retour INTEGER;
BEGIN
  -- Vérifier si l''admin existe déjà
  SELECT id_admin INTO id FROM admin WHERE login = p_login AND password = p_password;

  IF id IS NULL THEN
    -- Si l''admin n''existe pas, l''ajouter
    INSERT INTO admin (login, password) VALUES (p_login, p_password) RETURNING id_admin INTO id;

    -- Vérifier à nouveau après l''insertion
    IF id IS NULL THEN
      retour = -1;
    ELSE
      retour = 1;
    END IF;
  ELSE
    retour = 0;
  END IF;

  RETURN retour;
END;
';


--
-- TOC entry 272 (class 1255 OID 32841)
-- Name: ajout_client(text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ajout_client(p_nom text, p_prenom text, p_email text, p_adresse text, p_numero text, p_password text) RETURNS integer
    LANGUAGE plpgsql
    AS '
DECLARE
    client_id INTEGER;
BEGIN
    -- Insérer le nouveau client dans la table ti_client et récupérer l''identifiant généré
    INSERT INTO ti_client (nom, prenom, email, adresse, numero, password)
    VALUES (p_nom, p_prenom, p_email, p_adresse, p_numero, p_password)
    RETURNING id_client INTO client_id;

    -- Retourner l''identifiant du client nouvellement inséré
    RETURN client_id;
END;
';


--
-- TOC entry 278 (class 1255 OID 32947)
-- Name: ajout_produit(text, text, numeric, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ajout_produit(p_nom text, p_description text, p_prix numeric, p_categorie_id integer) RETURNS void
    LANGUAGE plpgsql
    AS '
BEGIN
    -- Insérer le nouveau produit dans la table ti_produits
    INSERT INTO ti_produits(nom, description, prix, categorie)
    VALUES (p_nom, p_description, p_prix, p_categorie_id);

    -- Afficher un message de confirmation
    RAISE NOTICE ''Le produit "%", a été ajouté avec succès.'', p_nom;

    -- Terminer la fonction avec succès
    RETURN;
EXCEPTION
    WHEN others THEN
        -- En cas d''erreur, afficher un message d''erreur
        RAISE EXCEPTION ''Erreur lors de l''''ajout du produit : %'', SQLERRM;
END;
';


--
-- TOC entry 274 (class 1255 OID 32821)
-- Name: ajouter_produit_panier(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ajouter_produit_panier(client_id integer, produit_id integer) RETURNS void
    LANGUAGE plpgsql
    AS '
DECLARE
    panier_id integer;
BEGIN
    -- Vérifier si le panier du client existe, sinon le créer
    INSERT INTO ti_panier (fk_client)
    VALUES (client_id)
    ON CONFLICT (fk_client) DO NOTHING;

    -- Récupérer l''identifiant du panier du client
    SELECT id_panier INTO panier_id
    FROM ti_panier
    WHERE fk_client = client_id;

    -- Ajouter le produit au panier (détail panier)
    INSERT INTO ti_detailpanier (fk_panier, fk_produit)
    VALUES (panier_id, produit_id);
END;
';


--
-- TOC entry 258 (class 1255 OID 32882)
-- Name: creer_panier(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.creer_panier(client_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS '
DECLARE
    panier_id integer;
BEGIN
    INSERT INTO ti_panier(client) VALUES (client_id) RETURNING id_panier INTO panier_id;
    RETURN panier_id;
END;
';


--
-- TOC entry 276 (class 1255 OID 32923)
-- Name: get_commandes_client(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_commandes_client(client_id integer) RETURNS TABLE(id_commande integer, date_commande date, statut_commande text, id_produit integer, nom_produit text, description_produit text, prix_produit numeric)
    LANGUAGE plpgsql
    AS '
BEGIN
    RETURN QUERY
    SELECT c.id_commande, c.date_commande, c.statut , p.id_produit, p.nom, p.description, p.prix
    FROM ti_produits p
    JOIN ti_detailcom dc ON p.id_produit = dc.produit_id
    JOIN ti_commande c ON dc.id_commande = c.id_commande
    WHERE c.client_id = get_commandes_client.client_id; -- Utilisation explicite de la variable client_id de la fonction
END;
';


--
-- TOC entry 277 (class 1255 OID 32921)
-- Name: passer_commande(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.passer_commande(client_id integer) RETURNS void
    LANGUAGE plpgsql
    AS '
DECLARE
    new_commande_id INT;
    panier_record RECORD;
BEGIN
    -- Créer une nouvelle commande
    INSERT INTO ti_commande (date_commande, client_id, statut)
    VALUES (CURRENT_DATE, client_id, ''En attente'')
    RETURNING id_commande INTO new_commande_id;

    -- Sélectionner les éléments du panier du client
    FOR panier_record IN 
        SELECT dp.id_detailpanier, dp.fk_produit
        FROM ti_detailpanier dp
        WHERE dp.fk_panier = (SELECT id_panier FROM ti_panier WHERE client = client_id)
    LOOP
        -- Récupérer le prix unitaire du produit depuis la table ti_produits
        DECLARE
            prix_unitaire NUMERIC;
        BEGIN
            SELECT prix INTO prix_unitaire
            FROM ti_produits
            WHERE id_produit = panier_record.fk_produit;

            -- Insérer chaque élément du panier dans les détails de la commande
            INSERT INTO ti_detailcom (id_commande, produit_id, prix_unitaire)
            VALUES (new_commande_id, panier_record.fk_produit, prix_unitaire);

            -- Supprimer l''élément du panier après avoir ajouté à la commande
            DELETE FROM ti_detailpanier WHERE id_detailpanier = panier_record.id_detailpanier;
        END;
    END LOOP;

    -- Supprimer le panier une fois la commande passée (facultatif, selon votre logique métier)
    DELETE FROM ti_panier WHERE client = client_id;
END;
';


--
-- TOC entry 273 (class 1255 OID 32886)
-- Name: produits_dans_panier(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.produits_dans_panier(client_id integer) RETURNS TABLE(product_id integer, product_name text, product_price numeric)
    LANGUAGE plpgsql
    AS '
BEGIN
    RETURN QUERY
        SELECT
            dp.fk_produit AS product_id,
            p.nom AS nom,
            p.prix AS prix
        FROM
            ti_detailpanier dp
        JOIN
            ti_panier pa ON dp.fk_panier = pa.id_panier
        JOIN
            ti_client c ON pa.client = c.id_client
        JOIN
            ti_produits p ON dp.fk_produit = p.id_produit
        WHERE
            c.id_client = client_id;
END;
';


--
-- TOC entry 275 (class 1255 OID 32888)
-- Name: supprimer_panier(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.supprimer_panier(client_id integer) RETURNS void
    LANGUAGE plpgsql
    AS '
DECLARE
    panier_id INT;
BEGIN
    -- Récupérer l''identifiant du panier du client
    SELECT id_panier INTO panier_id FROM ti_panier WHERE client = client_id LIMIT 1;

    -- Vérifier si un panier existe pour ce client
    IF panier_id IS NOT NULL THEN
        -- Supprimer les détails du panier
        DELETE FROM ti_detailpanier WHERE fk_panier = panier_id;

        -- Supprimer le panier
        DELETE FROM ti_panier WHERE id_panier = panier_id;
    ELSE
        RAISE EXCEPTION ''Aucun panier trouvé pour ce client.'';
    END IF;
END;
';


--
-- TOC entry 270 (class 1255 OID 32784)
-- Name: supprimer_produit(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.supprimer_produit(p_id_produit integer) RETURNS void
    LANGUAGE plpgsql
    AS '
DECLARE
    v_nom_produit TEXT;
BEGIN
    -- Récupérer le nom du produit à supprimer
    SELECT nom INTO v_nom_produit
    FROM ti_produits
    WHERE id_produit = p_id_produit;

    -- Vérifier si le produit existe avant de le supprimer
    IF v_nom_produit IS NOT NULL THEN
        -- Supprimer le produit de la table TI_Produits
        DELETE FROM ti_produits
        WHERE id_produit = p_id_produit;

        -- Afficher un message de succès (facultatif)
        RAISE NOTICE ''Le produit "%", a été supprimé avec succès.'', v_nom_produit;
    ELSE
        -- Afficher un message d''erreur si le produit n''existe pas
        RAISE EXCEPTION ''Impossible de trouver le produit avec l''''ID %.'', p_id_produit;
    END IF;
    
    -- Effectuer d''autres opérations si nécessaire
    
END;
';


--
-- TOC entry 271 (class 1255 OID 32822)
-- Name: supprimer_produit_panier(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.supprimer_produit_panier(client_id integer, produit_id integer) RETURNS void
    LANGUAGE plpgsql
    AS '
DECLARE
    panier_id integer;
BEGIN
    -- Récupérer l''identifiant du panier du client
    SELECT id_panier INTO panier_id
    FROM ti_panier
    WHERE fk_client = client_id;

    -- Supprimer l''élément du panier (détail panier) pour le produit spécifié
    DELETE FROM ti_detailpanier
    WHERE fk_panier = panier_id
    AND fk_produit = produit_id;
END;
';


--
-- TOC entry 257 (class 1255 OID 32844)
-- Name: verif_client(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verif_client(p_email text, p_password text) RETURNS integer
    LANGUAGE plpgsql
    AS '
DECLARE
    client_count INTEGER;
BEGIN
    -- Vérifier si le client existe avec le mail et le mot de passe donnés
    SELECT COUNT(*) INTO client_count
    FROM ti_client
    WHERE email = p_email AND password = p_password;

    -- Renvoyer 1 si le client existe, sinon renvoyer 0
    RETURN CASE WHEN client_count > 0 THEN 1 ELSE 0 END;
END;
';


--
-- TOC entry 256 (class 1255 OID 24580)
-- Name: verifier_admin(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verifier_admin(text, text) RETURNS integer
    LANGUAGE plpgsql
    AS '
	declare p_login alias for $1;
	declare p_password alias for $2;
	declare id integer;
	declare retour integer;
	
begin
	select into id id_admin from admin where login=p_login and password = p_password;
	if not found 
	then
	  retour = 0;
	else
	  retour =1;
	end if;  
	return retour;
end;
';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 246 (class 1259 OID 32769)
-- Name: ti_categorie; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ti_categorie (
    id_categorie integer NOT NULL,
    libelle text NOT NULL
);


--
-- TOC entry 245 (class 1259 OID 32768)
-- Name: TI_Categorie_id_categorie_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TI_Categorie_id_categorie_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5064 (class 0 OID 0)
-- Dependencies: 245
-- Name: TI_Categorie_id_categorie_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TI_Categorie_id_categorie_seq" OWNED BY public.ti_categorie.id_categorie;


--
-- TOC entry 239 (class 1259 OID 24742)
-- Name: ti_client; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ti_client (
    id_client integer NOT NULL,
    nom text NOT NULL,
    prenom text NOT NULL,
    email text,
    adresse text,
    numero text,
    password text
);


--
-- TOC entry 242 (class 1259 OID 24874)
-- Name: TI_Client_id_client_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ti_client ALTER COLUMN id_client ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."TI_Client_id_client_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 1000
    CACHE 1
);


--
-- TOC entry 241 (class 1259 OID 24757)
-- Name: ti_commande; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ti_commande (
    id_commande integer NOT NULL,
    date_commande date NOT NULL,
    client_id integer NOT NULL,
    statut text NOT NULL
);


--
-- TOC entry 243 (class 1259 OID 24886)
-- Name: TI_Commande_id_commande_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ti_commande ALTER COLUMN id_commande ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."TI_Commande_id_commande_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 1000
    CACHE 1
);


--
-- TOC entry 240 (class 1259 OID 24749)
-- Name: ti_produits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ti_produits (
    id_produit integer NOT NULL,
    nom text NOT NULL,
    description text,
    prix numeric,
    categorie integer,
    image text
);


--
-- TOC entry 244 (class 1259 OID 24888)
-- Name: TI_Produits_id_produit_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ti_produits ALTER COLUMN id_produit ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."TI_Produits_id_produit_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 1000
    CACHE 1
);


--
-- TOC entry 215 (class 1259 OID 24581)
-- Name: admin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin (
    id_admin integer NOT NULL,
    login text,
    password text
);


--
-- TOC entry 216 (class 1259 OID 24586)
-- Name: admin_id_admin_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_id_admin_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 217 (class 1259 OID 24587)
-- Name: categorie; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categorie (
    id_categorie integer NOT NULL,
    nom_categorie text NOT NULL
);


--
-- TOC entry 218 (class 1259 OID 24592)
-- Name: categorie_id_categorie_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categorie_id_categorie_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5065 (class 0 OID 0)
-- Dependencies: 218
-- Name: categorie_id_categorie_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categorie_id_categorie_seq OWNED BY public.categorie.id_categorie;


--
-- TOC entry 219 (class 1259 OID 24593)
-- Name: client; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client (
    id_client integer NOT NULL,
    nom_client text NOT NULL,
    email text NOT NULL,
    adresse text NOT NULL,
    numero text NOT NULL,
    id_ville integer NOT NULL
);


--
-- TOC entry 220 (class 1259 OID 24598)
-- Name: client_id_client_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_id_client_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5066 (class 0 OID 0)
-- Dependencies: 220
-- Name: client_id_client_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_id_client_seq OWNED BY public.client.id_client;


--
-- TOC entry 221 (class 1259 OID 24599)
-- Name: facture; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.facture (
    id_facture integer NOT NULL,
    date_facture date NOT NULL,
    paye boolean NOT NULL,
    id_produit integer NOT NULL,
    id_client integer NOT NULL,
    prix money
);


--
-- TOC entry 222 (class 1259 OID 24602)
-- Name: facture_id_facture_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.facture_id_facture_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5067 (class 0 OID 0)
-- Dependencies: 222
-- Name: facture_id_facture_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.facture_id_facture_seq OWNED BY public.facture.id_facture;


--
-- TOC entry 223 (class 1259 OID 24603)
-- Name: livraison; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.livraison (
    id_livraison integer NOT NULL,
    id_magasin integer,
    id_facture integer
);


--
-- TOC entry 224 (class 1259 OID 24606)
-- Name: livraison_id_livraison_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.livraison_id_livraison_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5068 (class 0 OID 0)
-- Dependencies: 224
-- Name: livraison_id_livraison_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.livraison_id_livraison_seq OWNED BY public.livraison.id_livraison;


--
-- TOC entry 225 (class 1259 OID 24607)
-- Name: magasin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.magasin (
    id_magasin integer NOT NULL,
    nom_magasin text NOT NULL,
    adresse text NOT NULL,
    numero text NOT NULL,
    localite text,
    code_postal text,
    id_ville integer NOT NULL
);


--
-- TOC entry 226 (class 1259 OID 24612)
-- Name: magasin_id_magasin_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.magasin_id_magasin_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5069 (class 0 OID 0)
-- Dependencies: 226
-- Name: magasin_id_magasin_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.magasin_id_magasin_seq OWNED BY public.magasin.id_magasin;


--
-- TOC entry 227 (class 1259 OID 24613)
-- Name: panier; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.panier (
    id_panier integer NOT NULL,
    quantite integer NOT NULL,
    id_client integer NOT NULL,
    id_produit integer NOT NULL
);


--
-- TOC entry 228 (class 1259 OID 24616)
-- Name: panier_id_panier_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.panier_id_panier_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5070 (class 0 OID 0)
-- Dependencies: 228
-- Name: panier_id_panier_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.panier_id_panier_seq OWNED BY public.panier.id_panier;


--
-- TOC entry 229 (class 1259 OID 24617)
-- Name: pays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pays (
    id_pays integer NOT NULL,
    nom_pays text NOT NULL
);


--
-- TOC entry 230 (class 1259 OID 24622)
-- Name: pays_id_pays_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pays_id_pays_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5071 (class 0 OID 0)
-- Dependencies: 230
-- Name: pays_id_pays_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pays_id_pays_seq OWNED BY public.pays.id_pays;


--
-- TOC entry 231 (class 1259 OID 24623)
-- Name: produit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.produit (
    id_produit integer NOT NULL,
    nom_produit text NOT NULL,
    prix double precision,
    stock integer,
    relais boolean,
    id_magasin integer NOT NULL,
    id_sous_categorie integer NOT NULL
);


--
-- TOC entry 232 (class 1259 OID 24628)
-- Name: produit_id_produit_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.produit_id_produit_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5072 (class 0 OID 0)
-- Dependencies: 232
-- Name: produit_id_produit_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.produit_id_produit_seq OWNED BY public.produit.id_produit;


--
-- TOC entry 233 (class 1259 OID 24629)
-- Name: sous_categorie; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sous_categorie (
    id_sous_categorie integer NOT NULL,
    nom_sous_categorie text NOT NULL,
    id_categorie integer NOT NULL
);


--
-- TOC entry 234 (class 1259 OID 24634)
-- Name: sous_categorie_id_sous_categorie_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sous_categorie_id_sous_categorie_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5073 (class 0 OID 0)
-- Dependencies: 234
-- Name: sous_categorie_id_sous_categorie_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sous_categorie_id_sous_categorie_seq OWNED BY public.sous_categorie.id_sous_categorie;


--
-- TOC entry 253 (class 1259 OID 32905)
-- Name: ti_detailcom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ti_detailcom (
    id_detailcom integer NOT NULL,
    id_commande integer,
    produit_id integer,
    prix_unitaire numeric(10,2)
);


--
-- TOC entry 252 (class 1259 OID 32904)
-- Name: ti_detailcom_id_detailcom_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ti_detailcom_id_detailcom_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5074 (class 0 OID 0)
-- Dependencies: 252
-- Name: ti_detailcom_id_detailcom_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ti_detailcom_id_detailcom_seq OWNED BY public.ti_detailcom.id_detailcom;


--
-- TOC entry 251 (class 1259 OID 32860)
-- Name: ti_detailpanier; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ti_detailpanier (
    id_detailpanier integer NOT NULL,
    fk_panier integer NOT NULL,
    fk_produit integer NOT NULL
);


--
-- TOC entry 250 (class 1259 OID 32859)
-- Name: ti_detailpanier_id_detailpanier_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ti_detailpanier_id_detailpanier_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5075 (class 0 OID 0)
-- Dependencies: 250
-- Name: ti_detailpanier_id_detailpanier_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ti_detailpanier_id_detailpanier_seq OWNED BY public.ti_detailpanier.id_detailpanier;


--
-- TOC entry 249 (class 1259 OID 32853)
-- Name: ti_panier; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ti_panier (
    id_panier integer NOT NULL,
    client integer NOT NULL
);


--
-- TOC entry 248 (class 1259 OID 32852)
-- Name: ti_panier_id_panier_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ti_panier_id_panier_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5076 (class 0 OID 0)
-- Dependencies: 248
-- Name: ti_panier_id_panier_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ti_panier_id_panier_seq OWNED BY public.ti_panier.id_panier;


--
-- TOC entry 235 (class 1259 OID 24635)
-- Name: ville; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ville (
    id_ville integer NOT NULL,
    nom_ville text NOT NULL,
    code_postal text NOT NULL,
    id_pays integer NOT NULL
);


--
-- TOC entry 236 (class 1259 OID 24640)
-- Name: ville_id_ville_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ville_id_ville_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5077 (class 0 OID 0)
-- Dependencies: 236
-- Name: ville_id_ville_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ville_id_ville_seq OWNED BY public.ville.id_ville;


--
-- TOC entry 237 (class 1259 OID 24641)
-- Name: vue_categorie_sous_categorie; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vue_categorie_sous_categorie AS
 SELECT c.id_categorie,
    c.nom_categorie,
    sc.id_sous_categorie,
    sc.nom_sous_categorie
   FROM (public.categorie c
     JOIN public.sous_categorie sc ON ((c.id_categorie = sc.id_categorie)));


--
-- TOC entry 254 (class 1259 OID 32938)
-- Name: vue_commandes_details; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vue_commandes_details AS
 SELECT c.id_commande,
    c.date_commande,
    c.client_id,
    c.statut,
    dc.id_detailcom,
    dc.produit_id,
    dc.prix_unitaire,
    p.nom AS nom_produit,
    p.description AS description_produit
   FROM ((public.ti_commande c
     JOIN public.ti_detailcom dc ON ((c.id_commande = dc.id_commande)))
     JOIN public.ti_produits p ON ((dc.produit_id = p.id_produit)));


--
-- TOC entry 238 (class 1259 OID 24645)
-- Name: vue_produits_cat_sous_cat_mag; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vue_produits_cat_sous_cat_mag AS
 SELECT vcs.id_categorie,
    vcs.nom_categorie,
    vcs.nom_sous_categorie,
    p.id_produit,
    p.nom_produit,
    p.prix,
    p.stock,
    p.relais,
    m.id_magasin,
    m.nom_magasin
   FROM ((public.vue_categorie_sous_categorie vcs
     JOIN public.produit p ON ((p.id_sous_categorie = vcs.id_sous_categorie)))
     JOIN public.magasin m ON ((p.id_magasin = m.id_magasin)));


--
-- TOC entry 247 (class 1259 OID 32823)
-- Name: vue_produits_par_categorie; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vue_produits_par_categorie AS
 SELECT p.id_produit,
    p.nom,
    p.description,
    p.prix,
    c.libelle AS categorie,
    c.id_categorie,
    p.image
   FROM (public.ti_produits p
     JOIN public.ti_categorie c ON ((p.categorie = c.id_categorie)));


--
-- TOC entry 4802 (class 2604 OID 24650)
-- Name: categorie id_categorie; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorie ALTER COLUMN id_categorie SET DEFAULT nextval('public.categorie_id_categorie_seq'::regclass);


--
-- TOC entry 4803 (class 2604 OID 24651)
-- Name: client id_client; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client ALTER COLUMN id_client SET DEFAULT nextval('public.client_id_client_seq'::regclass);


--
-- TOC entry 4804 (class 2604 OID 24652)
-- Name: facture id_facture; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facture ALTER COLUMN id_facture SET DEFAULT nextval('public.facture_id_facture_seq'::regclass);


--
-- TOC entry 4805 (class 2604 OID 24653)
-- Name: livraison id_livraison; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livraison ALTER COLUMN id_livraison SET DEFAULT nextval('public.livraison_id_livraison_seq'::regclass);


--
-- TOC entry 4806 (class 2604 OID 24654)
-- Name: magasin id_magasin; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.magasin ALTER COLUMN id_magasin SET DEFAULT nextval('public.magasin_id_magasin_seq'::regclass);


--
-- TOC entry 4807 (class 2604 OID 24655)
-- Name: panier id_panier; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.panier ALTER COLUMN id_panier SET DEFAULT nextval('public.panier_id_panier_seq'::regclass);


--
-- TOC entry 4808 (class 2604 OID 24656)
-- Name: pays id_pays; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pays ALTER COLUMN id_pays SET DEFAULT nextval('public.pays_id_pays_seq'::regclass);


--
-- TOC entry 4809 (class 2604 OID 24657)
-- Name: produit id_produit; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produit ALTER COLUMN id_produit SET DEFAULT nextval('public.produit_id_produit_seq'::regclass);


--
-- TOC entry 4810 (class 2604 OID 24658)
-- Name: sous_categorie id_sous_categorie; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sous_categorie ALTER COLUMN id_sous_categorie SET DEFAULT nextval('public.sous_categorie_id_sous_categorie_seq'::regclass);


--
-- TOC entry 4812 (class 2604 OID 32772)
-- Name: ti_categorie id_categorie; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_categorie ALTER COLUMN id_categorie SET DEFAULT nextval('public."TI_Categorie_id_categorie_seq"'::regclass);


--
-- TOC entry 4815 (class 2604 OID 32908)
-- Name: ti_detailcom id_detailcom; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_detailcom ALTER COLUMN id_detailcom SET DEFAULT nextval('public.ti_detailcom_id_detailcom_seq'::regclass);


--
-- TOC entry 4814 (class 2604 OID 32863)
-- Name: ti_detailpanier id_detailpanier; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_detailpanier ALTER COLUMN id_detailpanier SET DEFAULT nextval('public.ti_detailpanier_id_detailpanier_seq'::regclass);


--
-- TOC entry 4813 (class 2604 OID 32856)
-- Name: ti_panier id_panier; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_panier ALTER COLUMN id_panier SET DEFAULT nextval('public.ti_panier_id_panier_seq'::regclass);


--
-- TOC entry 4811 (class 2604 OID 24659)
-- Name: ville id_ville; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ville ALTER COLUMN id_ville SET DEFAULT nextval('public.ville_id_ville_seq'::regclass);


--
-- TOC entry 5022 (class 0 OID 24581)
-- Dependencies: 215
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.admin (id_admin, login, password) VALUES (4, 'Louis', 'Louis');
INSERT INTO public.admin (id_admin, login, password) VALUES (2, 'Pierre', 'Pierre');
INSERT INTO public.admin (id_admin, login, password) VALUES (3, 'Emma', 'Emma');
INSERT INTO public.admin (id_admin, login, password) VALUES (5, 'Bob', 'Bob');
INSERT INTO public.admin (id_admin, login, password) VALUES (9, 'Fred', 'Fred');
INSERT INTO public.admin (id_admin, login, password) VALUES (10, 'Marie', 'Marie');


--
-- TOC entry 5024 (class 0 OID 24587)
-- Dependencies: 217
-- Data for Name: categorie; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.categorie (id_categorie, nom_categorie) VALUES (1, 'Boucherie');
INSERT INTO public.categorie (id_categorie, nom_categorie) VALUES (2, 'Boulangerie');
INSERT INTO public.categorie (id_categorie, nom_categorie) VALUES (3, 'Epicerie');
INSERT INTO public.categorie (id_categorie, nom_categorie) VALUES (4, 'Ménage');
INSERT INTO public.categorie (id_categorie, nom_categorie) VALUES (5, 'Papeterie');
INSERT INTO public.categorie (id_categorie, nom_categorie) VALUES (6, 'Animaux');
INSERT INTO public.categorie (id_categorie, nom_categorie) VALUES (7, 'Fruits et légumes');
INSERT INTO public.categorie (id_categorie, nom_categorie) VALUES (8, 'Produits laitiers');


--
-- TOC entry 5026 (class 0 OID 24593)
-- Dependencies: 219
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5028 (class 0 OID 24599)
-- Dependencies: 221
-- Data for Name: facture; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5030 (class 0 OID 24603)
-- Dependencies: 223
-- Data for Name: livraison; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5032 (class 0 OID 24607)
-- Dependencies: 225
-- Data for Name: magasin; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.magasin (id_magasin, nom_magasin, adresse, numero, localite, code_postal, id_ville) VALUES (2, 'Chez Jacques', 'Rue des écoles', '154', NULL, NULL, 3);
INSERT INTO public.magasin (id_magasin, nom_magasin, adresse, numero, localite, code_postal, id_ville) VALUES (3, 'Chez Ignace', 'Rue de la ferme', '19', NULL, NULL, 4);
INSERT INTO public.magasin (id_magasin, nom_magasin, adresse, numero, localite, code_postal, id_ville) VALUES (4, 'Chez Arthur', 'Rue des bois', '29', NULL, NULL, 3);
INSERT INTO public.magasin (id_magasin, nom_magasin, adresse, numero, localite, code_postal, id_ville) VALUES (5, 'Chez Margot', 'Rue de la poste', '84', NULL, NULL, 4);


--
-- TOC entry 5034 (class 0 OID 24613)
-- Dependencies: 227
-- Data for Name: panier; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5036 (class 0 OID 24617)
-- Dependencies: 229
-- Data for Name: pays; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.pays (id_pays, nom_pays) VALUES (1, 'Belgique');
INSERT INTO public.pays (id_pays, nom_pays) VALUES (2, 'France');


--
-- TOC entry 5038 (class 0 OID 24623)
-- Dependencies: 231
-- Data for Name: produit; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (1, 'Glacé', 3.5, 8, NULL, 2, 7);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (2, 'Riz', 5.7, 8, NULL, 3, 5);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (3, 'Ebly', 4.5, 16, NULL, 3, 5);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (4, 'Semoule moyen', 4.19, 11, NULL, 3, 5);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (5, 'Félix Duo', 5.75, 18, NULL, 3, 3);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (6, 'Whiskas Poisson', 6.51, 21, NULL, 3, 3);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (7, 'Croquettes Gourmet', 7.24, 10, NULL, 3, 3);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (8, 'Pommes Grany Smith', 3.15, 20, NULL, 3, 9);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (9, 'Poires Williams', 2.51, 12, NULL, 3, 9);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (10, 'Oranges de table', 4.24, 12, NULL, 3, 9);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (11, 'Clémentines', 4.11, 19, NULL, 3, 9);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (12, 'Bananes', 1.2, 19, NULL, 3, 9);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (13, 'Laitues', 0.85, 20, NULL, 3, 11);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (14, 'Carottes', 3, 12, NULL, 3, 11);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (15, 'Poireaux', 2.24, 15, NULL, 3, 11);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (16, 'Navets', 2.4, 19, NULL, 3, 11);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (17, 'Céleri', 1.26, 4, NULL, 3, 11);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (19, 'Poulet', 8.75, 11, NULL, 2, 6);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (20, 'Dinde', 6.51, 21, NULL, 2, 6);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie) VALUES (21, 'Caille', 17.24, 5, NULL, 2, 6);


--
-- TOC entry 5040 (class 0 OID 24629)
-- Dependencies: 233
-- Data for Name: sous_categorie; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie) VALUES (6, 'Volaille', 1);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie) VALUES (7, 'Pains', 2);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie) VALUES (5, 'Féculents', 3);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie) VALUES (4, 'Pâtisserie', 2);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie) VALUES (10, 'Vaisselle', 4);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie) VALUES (2, 'Entretien', 4);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie) VALUES (9, 'Fruits', 7);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie) VALUES (11, 'Légumes', 7);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie) VALUES (1, 'Traiteur', 1);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie) VALUES (3, 'Animaux', 4);


--
-- TOC entry 5051 (class 0 OID 32769)
-- Dependencies: 246
-- Data for Name: ti_categorie; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ti_categorie (id_categorie, libelle) VALUES (1, 'Ordinateur Portable
');
INSERT INTO public.ti_categorie (id_categorie, libelle) VALUES (2, 'Ordinateur monté
');
INSERT INTO public.ti_categorie (id_categorie, libelle) VALUES (3, 'PC Gamer
');
INSERT INTO public.ti_categorie (id_categorie, libelle) VALUES (4, 'Processeur
');
INSERT INTO public.ti_categorie (id_categorie, libelle) VALUES (5, 'Carte Graphique');
INSERT INTO public.ti_categorie (id_categorie, libelle) VALUES (6, 'Boitier PC');
INSERT INTO public.ti_categorie (id_categorie, libelle) VALUES (7, 'Alimentation PC');
INSERT INTO public.ti_categorie (id_categorie, libelle) VALUES (8, 'Carte Mère ');
INSERT INTO public.ti_categorie (id_categorie, libelle) VALUES (9, 'Stockage');
INSERT INTO public.ti_categorie (id_categorie, libelle) VALUES (10, 'Mémoire RAM');
INSERT INTO public.ti_categorie (id_categorie, libelle) VALUES (11, 'Ventirad');


--
-- TOC entry 5044 (class 0 OID 24742)
-- Dependencies: 239
-- Data for Name: ti_client; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ti_client (id_client, nom, prenom, email, adresse, numero, password) OVERRIDING SYSTEM VALUE VALUES (2, 'Lefebvre', 'Marie', 'marielefebvre@outlook.com', 'rue de la paix , mons
', '45345312', 'lefebvre');
INSERT INTO public.ti_client (id_client, nom, prenom, email, adresse, numero, password) OVERRIDING SYSTEM VALUE VALUES (4, 'Bernard
', 'Pierre', 'pierreBernard@gmail.com', 'boulevard Voltaire , bruxelles', '123213475', 'bernard');
INSERT INTO public.ti_client (id_client, nom, prenom, email, adresse, numero, password) OVERRIDING SYSTEM VALUE VALUES (5, 'Dubois', 'Elise
', 'elise.dubois@outlook.com', 'rue de la fontaine , charleroi', '45645612', 'dubois');
INSERT INTO public.ti_client (id_client, nom, prenom, email, adresse, numero, password) OVERRIDING SYSTEM VALUE VALUES (6, 'Doe', 'John', 'john.doe@example.com', '123 Main St', '123456789', 'doe');
INSERT INTO public.ti_client (id_client, nom, prenom, email, adresse, numero, password) OVERRIDING SYSTEM VALUE VALUES (8, 'azdazdaz', 'azdazdazd', 'azdazdazdazd@gmail.com', 'azdazfazfaz', '5161651', 'azeazeazeaz');
INSERT INTO public.ti_client (id_client, nom, prenom, email, adresse, numero, password) OVERRIDING SYSTEM VALUE VALUES (21, 'test', 'test', 'test@gmail.com', 'zadadzadaz', '8745615616', 'test');
INSERT INTO public.ti_client (id_client, nom, prenom, email, adresse, numero, password) OVERRIDING SYSTEM VALUE VALUES (1, 'Dupont', 'Jean', 'jeandupont@gmail.com', 'rue du pont , tournai', '7575678', 'dupont');


--
-- TOC entry 5046 (class 0 OID 24757)
-- Dependencies: 241
-- Data for Name: ti_commande; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ti_commande (id_commande, date_commande, client_id, statut) OVERRIDING SYSTEM VALUE VALUES (1, '2024-03-24', 1, 'Livrée');
INSERT INTO public.ti_commande (id_commande, date_commande, client_id, statut) OVERRIDING SYSTEM VALUE VALUES (2, '2024-03-30', 2, 'En attente');
INSERT INTO public.ti_commande (id_commande, date_commande, client_id, statut) OVERRIDING SYSTEM VALUE VALUES (3, '2024-02-03', 4, 'En attente');
INSERT INTO public.ti_commande (id_commande, date_commande, client_id, statut) OVERRIDING SYSTEM VALUE VALUES (74, '2024-04-30', 21, 'En attente');
INSERT INTO public.ti_commande (id_commande, date_commande, client_id, statut) OVERRIDING SYSTEM VALUE VALUES (75, '2024-04-30', 21, 'En attente');
INSERT INTO public.ti_commande (id_commande, date_commande, client_id, statut) OVERRIDING SYSTEM VALUE VALUES (76, '2024-04-30', 21, 'En attente');


--
-- TOC entry 5057 (class 0 OID 32905)
-- Dependencies: 253
-- Data for Name: ti_detailcom; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ti_detailcom (id_detailcom, id_commande, produit_id, prix_unitaire) VALUES (16, 74, 11, 660.00);
INSERT INTO public.ti_detailcom (id_detailcom, id_commande, produit_id, prix_unitaire) VALUES (17, 74, 2, 1200.00);
INSERT INTO public.ti_detailcom (id_detailcom, id_commande, produit_id, prix_unitaire) VALUES (18, 74, 4, 120.00);
INSERT INTO public.ti_detailcom (id_detailcom, id_commande, produit_id, prix_unitaire) VALUES (19, 75, 3, 150.00);
INSERT INTO public.ti_detailcom (id_detailcom, id_commande, produit_id, prix_unitaire) VALUES (20, 75, 3, 150.00);
INSERT INTO public.ti_detailcom (id_detailcom, id_commande, produit_id, prix_unitaire) VALUES (21, 76, 10, 550.00);


--
-- TOC entry 5055 (class 0 OID 32860)
-- Dependencies: 251
-- Data for Name: ti_detailpanier; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5053 (class 0 OID 32853)
-- Dependencies: 249
-- Data for Name: ti_panier; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ti_panier (id_panier, client) VALUES (30, 6);
INSERT INTO public.ti_panier (id_panier, client) VALUES (47, 21);
INSERT INTO public.ti_panier (id_panier, client) VALUES (7, 2);
INSERT INTO public.ti_panier (id_panier, client) VALUES (9, 1);


--
-- TOC entry 5045 (class 0 OID 24749)
-- Dependencies: 240
-- Data for Name: ti_produits; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (8, 'CPU Intel Core I5', 'Processeur Intel Core I5-12400F (2.5Ghz)', 120, 4, './admin/public/images/processeur/4.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (19, 'GTX 1060', 'carte graphique nvidia', 100, 5, NULL);
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (21, 'azdodjkaz', 'adzopdkzapo', 200, 11, NULL);
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (22, 'azdodjkaz', 'adzopdkzapo', 200, 11, NULL);
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (24, 'Crucial RAM 16 Go', 'DDR5 4800 Mhz', 50, 10, './admin/public/images/ram/2.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (10, 'ASUS Vivobook S15', 'Ordinateur Portable 15.6" Full HD - AMD Ryzen 5 7250U - 8 Go DDR5 - SSD 512 Go - Windows 11', 550, 1, './admin/public/images/portable/1.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (11, 'PC Work Bronze Pro Intel', 'PC FIXE Intel Core i5-12400 - 16 Go DDR4 - SSD 1 To PCIe 4.0 - WiFi - Windows 11', 660, 2, './admin/public/images/fixe/1.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (12, 'PC Gamer Delta ', 'PC Gamer AMD Ryzen 5 7500F - Radeon RX 7600 XT - 16 Go DDR5 - SSD 1 To PCIe 4.0 - WiFi - Windows 11', 1300, 3, './admin/public/images/gamer/1.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (2, 'GPU RTX 3080', 'Carte graphique gaming de pointe, 10 Go de mémoire GDDR6X, fréquence boost jusqu''à 1710 MHz', 1200, 5, './admin/public/images/gpu/2.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (9, 'GPU RTX 4070', 'Carte graphique - Refroidissement semi-passif (mode 0 dB) - 12 Go GDDR6X / Alimentation PC Certifiée 80+ Gold - Modulaire - ATX 3.0', 700, 5, './admin/public/images/gpu/1.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (6, 'CPU Intel Core I3', 'Processeur Intel Core I3
', 70, 4, './admin/public/images/processeur/1.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (13, 'Corsair 4000D Airflow - Noir', 'Boitier PC Moyen Tour - E-ATX / ATX / mATX / Mini-ITX - USB 3.1 Type C - Avec fenêtre (pleine taille)', 100, 6, './admin/public/images/boitier/1.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (14, 'Fox Spirit HG850 - 850W', 'Alimentation PC Certifiée 80+ Gold - Modulaire - ATX 3.0', 120, 7, './admin/public/images/alimentation/1.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (5, 'Carte mère Asus Z590', 'Carte mère avec chipset Z590, supporte les derniers processeurs Intel, USB 3.2 Gen 2, PCIe 4.0', 250, 8, './admin/public/images/motherboard/1.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (3, 'SSD Samsung 1To
', 'Disque SSD haute vitesse, lecture jusqu''à 550 Mo/s, écriture jusqu''à 520 Mo/s', 150, 9, './admin/public/images/stockage/1.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (4, 'RAM DDR4 16Go', 'Module de mémoire DDR4 16 Go, fréquence 3200 MHz, idéal pour les configurations gaming et multitâches', 120, 10, './admin/public/images/ram/1.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (15, 'Fox Spirit Cold Snap VT120 Black V2', 'Ventirad Tour - PWM - Socket AMD AM5 / AM4 et Intel 115x / 1200 / 1700', 34, 11, './admin/public/images/ventirad/1.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (1, 'CPU Intel Core I7', 'Processeur Intel Core i7 : 
Processeur hautes performances pour les tâches multitâches, fréquence 3.5 GHz, 8 cœurs', 350, 4, './admin/public/images/processeur/5.jpg');
INSERT INTO public.ti_produits (id_produit, nom, description, prix, categorie, image) OVERRIDING SYSTEM VALUE VALUES (7, 'CPU AMD Ryzen 5 ', 'Processeur AMD Ryzen 5 5500 (3.6GHz)
', 113, 4, './admin/public/images/processeur/3.jpg');


--
-- TOC entry 5042 (class 0 OID 24635)
-- Dependencies: 235
-- Data for Name: ville; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ville (id_ville, nom_ville, code_postal, id_pays) VALUES (1, 'Peruwelz', '7060', 1);
INSERT INTO public.ville (id_ville, nom_ville, code_postal, id_pays) VALUES (2, 'Quiévrechain', '59920', 2);
INSERT INTO public.ville (id_ville, nom_ville, code_postal, id_pays) VALUES (3, 'Quiévrain', '7380', 1);
INSERT INTO public.ville (id_ville, nom_ville, code_postal, id_pays) VALUES (4, 'Crespin', '59154', 2);
INSERT INTO public.ville (id_ville, nom_ville, code_postal, id_pays) VALUES (5, 'Quarouble', '59243', 2);
INSERT INTO public.ville (id_ville, nom_ville, code_postal, id_pays) VALUES (6, 'Hensies', '7350', 1);


--
-- TOC entry 5078 (class 0 OID 0)
-- Dependencies: 245
-- Name: TI_Categorie_id_categorie_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TI_Categorie_id_categorie_seq"', 12, true);


--
-- TOC entry 5079 (class 0 OID 0)
-- Dependencies: 242
-- Name: TI_Client_id_client_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TI_Client_id_client_seq"', 22, true);


--
-- TOC entry 5080 (class 0 OID 0)
-- Dependencies: 243
-- Name: TI_Commande_id_commande_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TI_Commande_id_commande_seq"', 76, true);


--
-- TOC entry 5081 (class 0 OID 0)
-- Dependencies: 244
-- Name: TI_Produits_id_produit_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TI_Produits_id_produit_seq"', 24, true);


--
-- TOC entry 5082 (class 0 OID 0)
-- Dependencies: 216
-- Name: admin_id_admin_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.admin_id_admin_seq', 10, true);


--
-- TOC entry 5083 (class 0 OID 0)
-- Dependencies: 218
-- Name: categorie_id_categorie_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categorie_id_categorie_seq', 8, true);


--
-- TOC entry 5084 (class 0 OID 0)
-- Dependencies: 220
-- Name: client_id_client_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.client_id_client_seq', 1, false);


--
-- TOC entry 5085 (class 0 OID 0)
-- Dependencies: 222
-- Name: facture_id_facture_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.facture_id_facture_seq', 1, false);


--
-- TOC entry 5086 (class 0 OID 0)
-- Dependencies: 224
-- Name: livraison_id_livraison_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.livraison_id_livraison_seq', 1, false);


--
-- TOC entry 5087 (class 0 OID 0)
-- Dependencies: 226
-- Name: magasin_id_magasin_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.magasin_id_magasin_seq', 5, true);


--
-- TOC entry 5088 (class 0 OID 0)
-- Dependencies: 228
-- Name: panier_id_panier_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.panier_id_panier_seq', 1, false);


--
-- TOC entry 5089 (class 0 OID 0)
-- Dependencies: 230
-- Name: pays_id_pays_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pays_id_pays_seq', 2, true);


--
-- TOC entry 5090 (class 0 OID 0)
-- Dependencies: 232
-- Name: produit_id_produit_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.produit_id_produit_seq', 1, false);


--
-- TOC entry 5091 (class 0 OID 0)
-- Dependencies: 234
-- Name: sous_categorie_id_sous_categorie_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sous_categorie_id_sous_categorie_seq', 11, true);


--
-- TOC entry 5092 (class 0 OID 0)
-- Dependencies: 252
-- Name: ti_detailcom_id_detailcom_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ti_detailcom_id_detailcom_seq', 21, true);


--
-- TOC entry 5093 (class 0 OID 0)
-- Dependencies: 250
-- Name: ti_detailpanier_id_detailpanier_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ti_detailpanier_id_detailpanier_seq', 34, true);


--
-- TOC entry 5094 (class 0 OID 0)
-- Dependencies: 248
-- Name: ti_panier_id_panier_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ti_panier_id_panier_seq', 47, true);


--
-- TOC entry 5095 (class 0 OID 0)
-- Dependencies: 236
-- Name: ville_id_ville_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ville_id_ville_seq', 6, true);


--
-- TOC entry 4847 (class 2606 OID 32776)
-- Name: ti_categorie TI_Categorie_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_categorie
    ADD CONSTRAINT "TI_Categorie_pkey" PRIMARY KEY (id_categorie);


--
-- TOC entry 4839 (class 2606 OID 24816)
-- Name: ti_client TI_Client_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_client
    ADD CONSTRAINT "TI_Client_pkey" PRIMARY KEY (id_client);


--
-- TOC entry 4845 (class 2606 OID 24876)
-- Name: ti_commande TI_Commande_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_commande
    ADD CONSTRAINT "TI_Commande_pkey" PRIMARY KEY (id_commande);


--
-- TOC entry 4843 (class 2606 OID 24862)
-- Name: ti_produits TI_Produits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_produits
    ADD CONSTRAINT "TI_Produits_pkey" PRIMARY KEY (id_produit);


--
-- TOC entry 4817 (class 2606 OID 24661)
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (id_admin);


--
-- TOC entry 4819 (class 2606 OID 24663)
-- Name: categorie categorie_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorie
    ADD CONSTRAINT categorie_pkey PRIMARY KEY (id_categorie);


--
-- TOC entry 4821 (class 2606 OID 24665)
-- Name: client client_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (id_client);


--
-- TOC entry 4823 (class 2606 OID 24667)
-- Name: facture facture_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facture
    ADD CONSTRAINT facture_pkey PRIMARY KEY (id_facture);


--
-- TOC entry 4825 (class 2606 OID 24669)
-- Name: livraison livraison_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livraison
    ADD CONSTRAINT livraison_pkey PRIMARY KEY (id_livraison);


--
-- TOC entry 4827 (class 2606 OID 24671)
-- Name: magasin magasin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.magasin
    ADD CONSTRAINT magasin_pkey PRIMARY KEY (id_magasin);


--
-- TOC entry 4829 (class 2606 OID 24673)
-- Name: panier panier_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.panier
    ADD CONSTRAINT panier_pkey PRIMARY KEY (id_panier);


--
-- TOC entry 4831 (class 2606 OID 24675)
-- Name: pays pays_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pays
    ADD CONSTRAINT pays_pkey PRIMARY KEY (id_pays);


--
-- TOC entry 4833 (class 2606 OID 24677)
-- Name: produit produit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produit
    ADD CONSTRAINT produit_pkey PRIMARY KEY (id_produit);


--
-- TOC entry 4835 (class 2606 OID 24679)
-- Name: sous_categorie sous_categorie_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sous_categorie
    ADD CONSTRAINT sous_categorie_pkey PRIMARY KEY (id_sous_categorie);


--
-- TOC entry 4855 (class 2606 OID 32910)
-- Name: ti_detailcom ti_detailcom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_detailcom
    ADD CONSTRAINT ti_detailcom_pkey PRIMARY KEY (id_detailcom);


--
-- TOC entry 4853 (class 2606 OID 32865)
-- Name: ti_detailpanier ti_detailpanier_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_detailpanier
    ADD CONSTRAINT ti_detailpanier_pkey PRIMARY KEY (id_detailpanier);


--
-- TOC entry 4849 (class 2606 OID 32858)
-- Name: ti_panier ti_panier_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_panier
    ADD CONSTRAINT ti_panier_pkey PRIMARY KEY (id_panier);


--
-- TOC entry 4851 (class 2606 OID 32884)
-- Name: ti_panier unique_client; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_panier
    ADD CONSTRAINT unique_client UNIQUE (client) INCLUDE (client);


--
-- TOC entry 4841 (class 2606 OID 32843)
-- Name: ti_client unique_mail; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_client
    ADD CONSTRAINT unique_mail UNIQUE (email);


--
-- TOC entry 4837 (class 2606 OID 24681)
-- Name: ville ville_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ville
    ADD CONSTRAINT ville_pkey PRIMARY KEY (id_ville);


--
-- TOC entry 4856 (class 2606 OID 24682)
-- Name: client client_id_ville_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_id_ville_fkey FOREIGN KEY (id_ville) REFERENCES public.ville(id_ville);


--
-- TOC entry 4857 (class 2606 OID 24687)
-- Name: facture facture_id_client_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facture
    ADD CONSTRAINT facture_id_client_fkey FOREIGN KEY (id_client) REFERENCES public.client(id_client);


--
-- TOC entry 4858 (class 2606 OID 24692)
-- Name: facture facture_id_produit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facture
    ADD CONSTRAINT facture_id_produit_fkey FOREIGN KEY (id_produit) REFERENCES public.produit(id_produit);


--
-- TOC entry 4868 (class 2606 OID 32777)
-- Name: ti_produits fk_categorie; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_produits
    ADD CONSTRAINT fk_categorie FOREIGN KEY (categorie) REFERENCES public.ti_categorie(id_categorie);


--
-- TOC entry 4869 (class 2606 OID 24817)
-- Name: ti_commande fk_client; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_commande
    ADD CONSTRAINT fk_client FOREIGN KEY (client_id) REFERENCES public.ti_client(id_client) NOT VALID;


--
-- TOC entry 4870 (class 2606 OID 32876)
-- Name: ti_panier fk_client; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_panier
    ADD CONSTRAINT fk_client FOREIGN KEY (client) REFERENCES public.ti_client(id_client) NOT VALID;


--
-- TOC entry 4871 (class 2606 OID 32866)
-- Name: ti_detailpanier fk_panier; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_detailpanier
    ADD CONSTRAINT fk_panier FOREIGN KEY (fk_panier) REFERENCES public.ti_panier(id_panier) NOT VALID;


--
-- TOC entry 4872 (class 2606 OID 32871)
-- Name: ti_detailpanier fk_produit; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_detailpanier
    ADD CONSTRAINT fk_produit FOREIGN KEY (fk_produit) REFERENCES public.ti_produits(id_produit) NOT VALID;


--
-- TOC entry 4859 (class 2606 OID 24697)
-- Name: livraison livraison_id_facture_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livraison
    ADD CONSTRAINT livraison_id_facture_fkey FOREIGN KEY (id_facture) REFERENCES public.facture(id_facture);


--
-- TOC entry 4860 (class 2606 OID 24702)
-- Name: livraison livraison_id_magasin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livraison
    ADD CONSTRAINT livraison_id_magasin_fkey FOREIGN KEY (id_magasin) REFERENCES public.magasin(id_magasin);


--
-- TOC entry 4861 (class 2606 OID 24707)
-- Name: magasin magasin_id_ville_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.magasin
    ADD CONSTRAINT magasin_id_ville_fkey FOREIGN KEY (id_ville) REFERENCES public.ville(id_ville);


--
-- TOC entry 4862 (class 2606 OID 24712)
-- Name: panier panier_id_client_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.panier
    ADD CONSTRAINT panier_id_client_fkey FOREIGN KEY (id_client) REFERENCES public.client(id_client);


--
-- TOC entry 4863 (class 2606 OID 24717)
-- Name: panier panier_id_produit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.panier
    ADD CONSTRAINT panier_id_produit_fkey FOREIGN KEY (id_produit) REFERENCES public.produit(id_produit);


--
-- TOC entry 4864 (class 2606 OID 24722)
-- Name: produit produit_id_magasin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produit
    ADD CONSTRAINT produit_id_magasin_fkey FOREIGN KEY (id_magasin) REFERENCES public.magasin(id_magasin);


--
-- TOC entry 4865 (class 2606 OID 24727)
-- Name: produit produit_id_sous_categorie_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produit
    ADD CONSTRAINT produit_id_sous_categorie_fkey FOREIGN KEY (id_sous_categorie) REFERENCES public.sous_categorie(id_sous_categorie);


--
-- TOC entry 4866 (class 2606 OID 24732)
-- Name: sous_categorie sous_categorie_id_categorie_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sous_categorie
    ADD CONSTRAINT sous_categorie_id_categorie_fkey FOREIGN KEY (id_categorie) REFERENCES public.categorie(id_categorie);


--
-- TOC entry 4873 (class 2606 OID 32911)
-- Name: ti_detailcom ti_detailcom_id_commande_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_detailcom
    ADD CONSTRAINT ti_detailcom_id_commande_fkey FOREIGN KEY (id_commande) REFERENCES public.ti_commande(id_commande);


--
-- TOC entry 4874 (class 2606 OID 32916)
-- Name: ti_detailcom ti_detailcom_produit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ti_detailcom
    ADD CONSTRAINT ti_detailcom_produit_id_fkey FOREIGN KEY (produit_id) REFERENCES public.ti_produits(id_produit);


--
-- TOC entry 4867 (class 2606 OID 24737)
-- Name: ville ville_id_pays_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ville
    ADD CONSTRAINT ville_id_pays_fkey FOREIGN KEY (id_pays) REFERENCES public.pays(id_pays);


-- Completed on 2024-05-09 10:02:26

--
-- PostgreSQL database dump complete
--

