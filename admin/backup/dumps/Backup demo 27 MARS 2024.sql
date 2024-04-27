


--
-- TOC entry 231 (class 1255 OID 51383)
-- Name: ajout_admin(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ajout_admin(text, text) RETURNS integer
    LANGUAGE plpgsql
    AS '
  declare p_nom alias for $1;
  declare p_password alias for $2;
  declare id integer;
  declare retour integer;
  
  begin
  	select into id id_admin from admin where nom_admin = p_nom and password = p_password;
	if not found
	then
	  insert into admin (nom_admin,password) values (p_nom,p_password);
	  if not found
	  then
	  
	    retour = -1; -- échec insertion
	  else
	    retour = 1; -- insertion réussie
	  end if;
	else
	  retour = 0; --déjà en BD
	end if;
	
	return retour;
end;
';


--
-- TOC entry 233 (class 1255 OID 51664)
-- Name: ajout_client(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ajout_client(text, text, text, text, text) RETURNS integer
    LANGUAGE plpgsql
    AS '
  declare p_nom alias for $1;
  declare p_prenom alias for $2;
  declare p_email alias for $3;
  declare p_adresse alias for $4;
  declare p_numero alias for $5;
  declare id integer;
  declare retour integer;
  
begin
	select into id id_client from client where email = p_email;
	if not found
	then
	  insert into client (nom_client,prenom_client,email,adresse,numero) values
	    (p_nom,p_prenom,p_email,p_adresse,p_numero);
	  select into id id_client from client where email = p_email;
	  if not found
	  then	
	    retour = -1;  --échec de la requête
	  else
	    retour = 1;   -- insertion ok
	  end if;
	else
	  retour = 0;      -- déjà en BD
	end if;
 return retour;
 end;
';


--
-- TOC entry 229 (class 1255 OID 51377)
-- Name: getalladmintest1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getalladmintest1() RETURNS TABLE(id integer, nom text, email text)
    LANGUAGE plpgsql
    AS '
BEGIN
  RETURN QUERY
  SELECT * FROM admin;
END;
';


--
-- TOC entry 230 (class 1255 OID 51381)
-- Name: getalladmintest2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getalladmintest2() RETURNS SETOF record
    LANGUAGE plpgsql
    AS '
BEGIN
  RETURN QUERY SELECT id_admin, nom_admin, password FROM admin;
END;
';


--
-- TOC entry 232 (class 1255 OID 51663)
-- Name: verifier_admin(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verifier_admin(text, text) RETURNS integer
    LANGUAGE plpgsql
    AS '
  DECLARE p_login ALIAS FOR $1;
  DECLARE p_pass ALIAS for $2;
  DECLARE id integer;
  DECLARE retour integer;
BEGIN
  select into id id_admin from admin where nom_admin = p_login and password = p_pass;
  IF NOT FOUND
  THEN
    retour = 0;
  ELSE
    retour = 1;
  END IF;
   return retour;
 end;
  
';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 201 (class 1259 OID 51368)
-- Name: admin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin (
    id_admin integer NOT NULL,
    nom_admin text NOT NULL,
    password text NOT NULL
);


--
-- TOC entry 200 (class 1259 OID 51366)
-- Name: admin_id_admin_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_id_admin_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3161 (class 0 OID 0)
-- Dependencies: 200
-- Name: admin_id_admin_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_id_admin_seq OWNED BY public.admin.id_admin;


--
-- TOC entry 203 (class 1259 OID 51458)
-- Name: categorie; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categorie (
    id_categorie integer NOT NULL,
    nom_categorie text NOT NULL,
    image_categorie text
);


--
-- TOC entry 202 (class 1259 OID 51456)
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
-- TOC entry 3162 (class 0 OID 0)
-- Dependencies: 202
-- Name: categorie_id_categorie_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categorie_id_categorie_seq OWNED BY public.categorie.id_categorie;


--
-- TOC entry 213 (class 1259 OID 51528)
-- Name: client; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client (
    id_client integer NOT NULL,
    nom_client text NOT NULL,
    email text NOT NULL,
    adresse text NOT NULL,
    numero text NOT NULL,
    id_ville integer,
    password text,
    prenom_client text
);


--
-- TOC entry 212 (class 1259 OID 51526)
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
-- TOC entry 3163 (class 0 OID 0)
-- Dependencies: 212
-- Name: client_id_client_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_id_client_seq OWNED BY public.client.id_client;


--
-- TOC entry 219 (class 1259 OID 51583)
-- Name: facture; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.facture (
    id_facture integer NOT NULL,
    date_facture date NOT NULL,
    paye boolean NOT NULL,
    prix_produit numeric(15,2) NOT NULL,
    id_produit integer NOT NULL,
    id_client integer NOT NULL
);


--
-- TOC entry 218 (class 1259 OID 51581)
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
-- TOC entry 3164 (class 0 OID 0)
-- Dependencies: 218
-- Name: facture_id_facture_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.facture_id_facture_seq OWNED BY public.facture.id_facture;


--
-- TOC entry 221 (class 1259 OID 51601)
-- Name: livraison; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.livraison (
    id_livraison integer NOT NULL,
    id_magasin integer,
    id_facture integer
);


--
-- TOC entry 220 (class 1259 OID 51599)
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
-- TOC entry 3165 (class 0 OID 0)
-- Dependencies: 220
-- Name: livraison_id_livraison_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.livraison_id_livraison_seq OWNED BY public.livraison.id_livraison;


--
-- TOC entry 211 (class 1259 OID 51512)
-- Name: magasin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.magasin (
    id_magasin integer NOT NULL,
    nom_magasin text NOT NULL,
    adresse text NOT NULL,
    numero text NOT NULL,
    id_ville integer NOT NULL,
    image_magasin text
);


--
-- TOC entry 210 (class 1259 OID 51510)
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
-- TOC entry 3166 (class 0 OID 0)
-- Dependencies: 210
-- Name: magasin_id_magasin_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.magasin_id_magasin_seq OWNED BY public.magasin.id_magasin;


--
-- TOC entry 217 (class 1259 OID 51565)
-- Name: panier; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.panier (
    id_panier integer NOT NULL,
    quantite integer NOT NULL,
    id_client integer NOT NULL,
    id_produit integer NOT NULL
);


--
-- TOC entry 216 (class 1259 OID 51563)
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
-- TOC entry 3167 (class 0 OID 0)
-- Dependencies: 216
-- Name: panier_id_panier_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.panier_id_panier_seq OWNED BY public.panier.id_panier;


--
-- TOC entry 207 (class 1259 OID 51485)
-- Name: pays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pays (
    id_pays integer NOT NULL,
    nom_pays text NOT NULL
);


--
-- TOC entry 206 (class 1259 OID 51483)
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
-- TOC entry 3168 (class 0 OID 0)
-- Dependencies: 206
-- Name: pays_id_pays_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pays_id_pays_seq OWNED BY public.pays.id_pays;


--
-- TOC entry 215 (class 1259 OID 51544)
-- Name: produit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.produit (
    id_produit integer NOT NULL,
    nom_produit text NOT NULL,
    prix double precision,
    stock integer,
    relais boolean,
    id_magasin integer NOT NULL,
    id_sous_categorie integer NOT NULL,
    image_produit text
);


--
-- TOC entry 214 (class 1259 OID 51542)
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
-- TOC entry 3169 (class 0 OID 0)
-- Dependencies: 214
-- Name: produit_id_produit_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.produit_id_produit_seq OWNED BY public.produit.id_produit;


--
-- TOC entry 205 (class 1259 OID 51469)
-- Name: sous_categorie; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sous_categorie (
    id_sous_categorie integer NOT NULL,
    nom_sous_categorie text NOT NULL,
    id_categorie integer NOT NULL,
    image_sous_categorie text
);


--
-- TOC entry 204 (class 1259 OID 51467)
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
-- TOC entry 3170 (class 0 OID 0)
-- Dependencies: 204
-- Name: sous_categorie_id_sous_categorie_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sous_categorie_id_sous_categorie_seq OWNED BY public.sous_categorie.id_sous_categorie;


--
-- TOC entry 209 (class 1259 OID 51496)
-- Name: ville; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ville (
    id_ville integer NOT NULL,
    nom_ville text NOT NULL,
    code_postal text NOT NULL,
    id_pays integer NOT NULL
);


--
-- TOC entry 208 (class 1259 OID 51494)
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
-- TOC entry 3171 (class 0 OID 0)
-- Dependencies: 208
-- Name: ville_id_ville_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ville_id_ville_seq OWNED BY public.ville.id_ville;


--
-- TOC entry 222 (class 1259 OID 51618)
-- Name: vue_cat_sous_cat; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vue_cat_sous_cat AS
 SELECT categorie.id_categorie,
    categorie.nom_categorie,
    sous_categorie.id_sous_categorie,
    sous_categorie.nom_sous_categorie
   FROM public.categorie,
    public.sous_categorie
  WHERE (categorie.id_categorie = sous_categorie.id_categorie)
  ORDER BY categorie.id_categorie;


--
-- TOC entry 226 (class 1259 OID 51646)
-- Name: vue_produits_magasins2; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vue_produits_magasins2 AS
 SELECT produit.id_produit,
    produit.nom_produit,
    produit.prix,
    produit.stock,
    produit.relais,
    produit.image_produit,
    magasin.id_magasin,
    magasin.nom_magasin,
    magasin.adresse,
    magasin.numero,
    magasin.image_magasin
   FROM public.magasin,
    public.produit
  WHERE (magasin.id_magasin = produit.id_magasin);


--
-- TOC entry 228 (class 1259 OID 51658)
-- Name: vue_cat_sous_cat2; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vue_cat_sous_cat2 AS
 SELECT vue_cat_sous_cat.id_categorie,
    vue_cat_sous_cat.nom_categorie,
    vue_cat_sous_cat.id_sous_categorie,
    vue_cat_sous_cat.nom_sous_categorie,
    vue_produits_magasins2.id_produit,
    vue_produits_magasins2.nom_produit,
    vue_produits_magasins2.prix,
    vue_produits_magasins2.stock,
    vue_produits_magasins2.relais,
    vue_produits_magasins2.id_magasin,
    vue_produits_magasins2.nom_magasin,
    vue_produits_magasins2.adresse,
    vue_produits_magasins2.numero,
    vue_produits_magasins2.image_magasin
   FROM public.vue_produits_magasins2,
    public.produit,
    public.vue_cat_sous_cat
  WHERE ((vue_produits_magasins2.id_produit = produit.id_produit) AND (vue_cat_sous_cat.id_sous_categorie = produit.id_sous_categorie))
  ORDER BY vue_produits_magasins2.nom_produit;


--
-- TOC entry 225 (class 1259 OID 51642)
-- Name: vue_categ_sous_categ; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vue_categ_sous_categ AS
 SELECT categorie.id_categorie,
    categorie.nom_categorie,
    categorie.image_categorie,
    sous_categorie.id_sous_categorie,
    sous_categorie.nom_sous_categorie,
    sous_categorie.image_sous_categorie
   FROM public.categorie,
    public.sous_categorie
  WHERE (sous_categorie.id_categorie = categorie.id_categorie);


--
-- TOC entry 227 (class 1259 OID 51654)
-- Name: vue_magasin_ville; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vue_magasin_ville AS
 SELECT magasin.id_magasin,
    magasin.nom_magasin,
    magasin.adresse,
    magasin.numero,
    magasin.image_magasin,
    ville.id_ville,
    ville.nom_ville
   FROM public.ville,
    public.magasin
  WHERE (ville.id_ville = magasin.id_ville);


--
-- TOC entry 223 (class 1259 OID 51630)
-- Name: vue_produits_magasins; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vue_produits_magasins AS
 SELECT produit.id_produit,
    produit.nom_produit,
    produit.prix,
    produit.stock,
    produit.relais,
    magasin.id_magasin,
    magasin.nom_magasin,
    magasin.adresse,
    magasin.numero
   FROM public.magasin,
    public.produit
  WHERE (magasin.id_magasin = produit.id_magasin);


--
-- TOC entry 224 (class 1259 OID 51638)
-- Name: vue_produits_cat_magasin; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vue_produits_cat_magasin AS
 SELECT vue_cat_sous_cat.id_categorie,
    vue_cat_sous_cat.nom_categorie,
    vue_cat_sous_cat.id_sous_categorie,
    vue_cat_sous_cat.nom_sous_categorie,
    vue_produits_magasins.id_produit,
    vue_produits_magasins.nom_produit,
    vue_produits_magasins.prix,
    vue_produits_magasins.stock,
    vue_produits_magasins.relais,
    vue_produits_magasins.id_magasin,
    vue_produits_magasins.nom_magasin,
    vue_produits_magasins.adresse,
    vue_produits_magasins.numero
   FROM public.vue_produits_magasins,
    public.produit,
    public.vue_cat_sous_cat
  WHERE ((vue_produits_magasins.id_produit = produit.id_produit) AND (vue_cat_sous_cat.id_sous_categorie = produit.id_sous_categorie))
  ORDER BY vue_produits_magasins.nom_produit;


--
-- TOC entry 2951 (class 2604 OID 51371)
-- Name: admin id_admin; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin ALTER COLUMN id_admin SET DEFAULT nextval('public.admin_id_admin_seq'::regclass);


--
-- TOC entry 2952 (class 2604 OID 51461)
-- Name: categorie id_categorie; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorie ALTER COLUMN id_categorie SET DEFAULT nextval('public.categorie_id_categorie_seq'::regclass);


--
-- TOC entry 2957 (class 2604 OID 51531)
-- Name: client id_client; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client ALTER COLUMN id_client SET DEFAULT nextval('public.client_id_client_seq'::regclass);


--
-- TOC entry 2960 (class 2604 OID 51586)
-- Name: facture id_facture; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facture ALTER COLUMN id_facture SET DEFAULT nextval('public.facture_id_facture_seq'::regclass);


--
-- TOC entry 2961 (class 2604 OID 51604)
-- Name: livraison id_livraison; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livraison ALTER COLUMN id_livraison SET DEFAULT nextval('public.livraison_id_livraison_seq'::regclass);


--
-- TOC entry 2956 (class 2604 OID 51515)
-- Name: magasin id_magasin; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.magasin ALTER COLUMN id_magasin SET DEFAULT nextval('public.magasin_id_magasin_seq'::regclass);


--
-- TOC entry 2959 (class 2604 OID 51568)
-- Name: panier id_panier; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.panier ALTER COLUMN id_panier SET DEFAULT nextval('public.panier_id_panier_seq'::regclass);


--
-- TOC entry 2954 (class 2604 OID 51488)
-- Name: pays id_pays; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pays ALTER COLUMN id_pays SET DEFAULT nextval('public.pays_id_pays_seq'::regclass);


--
-- TOC entry 2958 (class 2604 OID 51547)
-- Name: produit id_produit; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produit ALTER COLUMN id_produit SET DEFAULT nextval('public.produit_id_produit_seq'::regclass);


--
-- TOC entry 2953 (class 2604 OID 51472)
-- Name: sous_categorie id_sous_categorie; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sous_categorie ALTER COLUMN id_sous_categorie SET DEFAULT nextval('public.sous_categorie_id_sous_categorie_seq'::regclass);


--
-- TOC entry 2955 (class 2604 OID 51499)
-- Name: ville id_ville; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ville ALTER COLUMN id_ville SET DEFAULT nextval('public.ville_id_ville_seq'::regclass);


--
-- TOC entry 3134 (class 0 OID 51368)
-- Dependencies: 201
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.admin (id_admin, nom_admin, password) VALUES (1, 'admin', 'admin');
INSERT INTO public.admin (id_admin, nom_admin, password) VALUES (2, 'Bob', 'Bob');
INSERT INTO public.admin (id_admin, nom_admin, password) VALUES (3, 'Lou', 'Lou');
INSERT INTO public.admin (id_admin, nom_admin, password) VALUES (4, 'Emy', 'Emy');
INSERT INTO public.admin (id_admin, nom_admin, password) VALUES (5, 'Fred', 'Fred');
INSERT INTO public.admin (id_admin, nom_admin, password) VALUES (6, 'Jenny', 'Jenny');


--
-- TOC entry 3136 (class 0 OID 51458)
-- Dependencies: 203
-- Data for Name: categorie; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.categorie (id_categorie, nom_categorie, image_categorie) VALUES (1, 'Boucherie', NULL);
INSERT INTO public.categorie (id_categorie, nom_categorie, image_categorie) VALUES (2, 'Boulangerie', NULL);
INSERT INTO public.categorie (id_categorie, nom_categorie, image_categorie) VALUES (3, 'Epicerie', NULL);
INSERT INTO public.categorie (id_categorie, nom_categorie, image_categorie) VALUES (4, 'Ménage', NULL);
INSERT INTO public.categorie (id_categorie, nom_categorie, image_categorie) VALUES (5, 'Papeterie', NULL);
INSERT INTO public.categorie (id_categorie, nom_categorie, image_categorie) VALUES (6, 'Animaux', NULL);
INSERT INTO public.categorie (id_categorie, nom_categorie, image_categorie) VALUES (7, 'Fruits et légumes', NULL);
INSERT INTO public.categorie (id_categorie, nom_categorie, image_categorie) VALUES (8, 'Produits laitiers', NULL);


--
-- TOC entry 3146 (class 0 OID 51528)
-- Dependencies: 213
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.client (id_client, nom_client, email, adresse, numero, id_ville, password, prenom_client) VALUES (1, 'Bob', 'bobby@bob.be', 'rue de la mer', '150', NULL, NULL, 'Bobby');
INSERT INTO public.client (id_client, nom_client, email, adresse, numero, id_ville, password, prenom_client) VALUES (2, '', 'aa@aa.be', 'aa', '5', NULL, NULL, 'aa');


--
-- TOC entry 3152 (class 0 OID 51583)
-- Dependencies: 219
-- Data for Name: facture; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3154 (class 0 OID 51601)
-- Dependencies: 221
-- Data for Name: livraison; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3144 (class 0 OID 51512)
-- Dependencies: 211
-- Data for Name: magasin; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.magasin (id_magasin, nom_magasin, adresse, numero, id_ville, image_magasin) VALUES (1, 'Chez Jacques', 'Rue des écoles', '154', 3, NULL);
INSERT INTO public.magasin (id_magasin, nom_magasin, adresse, numero, id_ville, image_magasin) VALUES (2, 'Chez Ignace', 'Rue de la ferme', '19', 4, NULL);
INSERT INTO public.magasin (id_magasin, nom_magasin, adresse, numero, id_ville, image_magasin) VALUES (3, 'Chez Arthur', 'Rue des bois', '29', 3, NULL);
INSERT INTO public.magasin (id_magasin, nom_magasin, adresse, numero, id_ville, image_magasin) VALUES (4, 'Chez Margot', 'Rue de la poste', '84', 4, NULL);


--
-- TOC entry 3150 (class 0 OID 51565)
-- Dependencies: 217
-- Data for Name: panier; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3140 (class 0 OID 51485)
-- Dependencies: 207
-- Data for Name: pays; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.pays (id_pays, nom_pays) VALUES (1, 'Belgique');
INSERT INTO public.pays (id_pays, nom_pays) VALUES (2, 'France');


--
-- TOC entry 3148 (class 0 OID 51544)
-- Dependencies: 215
-- Data for Name: produit; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (1, 'Glacé', 3.5, 8, NULL, 2, 7, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (2, 'Riz', 5.7, 8, NULL, 3, 5, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (3, 'Ebly', 4.5, 16, NULL, 3, 5, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (4, 'Semoule moyen', 4.19, 11, NULL, 3, 5, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (5, 'Félix Duo', 5.75, 18, NULL, 3, 3, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (6, 'Whiskas Poisson', 6.51, 21, NULL, 3, 3, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (7, 'Croquettes Gourmet', 7.24, 10, NULL, 3, 3, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (8, 'Pommes Grany Smith', 3.15, 20, NULL, 3, 9, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (9, 'Poires Williams', 2.51, 12, NULL, 3, 9, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (10, 'Oranges de table', 4.24, 12, NULL, 3, 9, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (11, 'Clémentines', 4.11, 19, NULL, 3, 9, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (12, 'Bananes', 1.2, 19, NULL, 3, 9, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (13, 'Laitues', 0.85, 20, NULL, 3, 11, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (14, 'Carottes', 3, 12, NULL, 3, 11, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (15, 'Poireaux', 2.24, 15, NULL, 3, 11, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (16, 'Navets', 2.4, 19, NULL, 3, 11, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (17, 'Céleri', 1.26, 4, NULL, 3, 11, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (19, 'Poulet', 8.75, 11, NULL, 1, 6, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (20, 'Dinde', 6.51, 21, NULL, 1, 6, NULL);
INSERT INTO public.produit (id_produit, nom_produit, prix, stock, relais, id_magasin, id_sous_categorie, image_produit) VALUES (21, 'Caille', 17.24, 5, NULL, 1, 6, NULL);


--
-- TOC entry 3138 (class 0 OID 51469)
-- Dependencies: 205
-- Data for Name: sous_categorie; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie, image_sous_categorie) VALUES (6, 'Volaille', 1, NULL);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie, image_sous_categorie) VALUES (7, 'Pains', 2, NULL);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie, image_sous_categorie) VALUES (5, 'Féculents', 3, NULL);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie, image_sous_categorie) VALUES (4, 'Pâtisserie', 2, NULL);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie, image_sous_categorie) VALUES (10, 'Vaisselle', 4, NULL);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie, image_sous_categorie) VALUES (2, 'Entretien', 4, NULL);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie, image_sous_categorie) VALUES (9, 'Fruits', 7, NULL);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie, image_sous_categorie) VALUES (11, 'Légumes', 7, NULL);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie, image_sous_categorie) VALUES (1, 'Traiteur', 1, NULL);
INSERT INTO public.sous_categorie (id_sous_categorie, nom_sous_categorie, id_categorie, image_sous_categorie) VALUES (3, 'Animaux', 4, NULL);


--
-- TOC entry 3142 (class 0 OID 51496)
-- Dependencies: 209
-- Data for Name: ville; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ville (id_ville, nom_ville, code_postal, id_pays) VALUES (1, 'Peruwelz', '7060', 1);
INSERT INTO public.ville (id_ville, nom_ville, code_postal, id_pays) VALUES (2, 'Quiévrechain', '59920', 2);
INSERT INTO public.ville (id_ville, nom_ville, code_postal, id_pays) VALUES (3, 'Quiévrain', '7380', 1);
INSERT INTO public.ville (id_ville, nom_ville, code_postal, id_pays) VALUES (4, 'Crespin', '59154', 2);
INSERT INTO public.ville (id_ville, nom_ville, code_postal, id_pays) VALUES (5, 'Quarouble', '59243', 2);
INSERT INTO public.ville (id_ville, nom_ville, code_postal, id_pays) VALUES (6, 'Hensies', '7350', 1);


--
-- TOC entry 3172 (class 0 OID 0)
-- Dependencies: 200
-- Name: admin_id_admin_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.admin_id_admin_seq', 6, true);


--
-- TOC entry 3173 (class 0 OID 0)
-- Dependencies: 202
-- Name: categorie_id_categorie_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categorie_id_categorie_seq', 8, true);


--
-- TOC entry 3174 (class 0 OID 0)
-- Dependencies: 212
-- Name: client_id_client_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.client_id_client_seq', 2, true);


--
-- TOC entry 3175 (class 0 OID 0)
-- Dependencies: 218
-- Name: facture_id_facture_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.facture_id_facture_seq', 1, false);


--
-- TOC entry 3176 (class 0 OID 0)
-- Dependencies: 220
-- Name: livraison_id_livraison_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.livraison_id_livraison_seq', 1, false);


--
-- TOC entry 3177 (class 0 OID 0)
-- Dependencies: 210
-- Name: magasin_id_magasin_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.magasin_id_magasin_seq', 4, true);


--
-- TOC entry 3178 (class 0 OID 0)
-- Dependencies: 216
-- Name: panier_id_panier_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.panier_id_panier_seq', 1, false);


--
-- TOC entry 3179 (class 0 OID 0)
-- Dependencies: 206
-- Name: pays_id_pays_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pays_id_pays_seq', 2, true);


--
-- TOC entry 3180 (class 0 OID 0)
-- Dependencies: 214
-- Name: produit_id_produit_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.produit_id_produit_seq', 21, true);


--
-- TOC entry 3181 (class 0 OID 0)
-- Dependencies: 204
-- Name: sous_categorie_id_sous_categorie_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sous_categorie_id_sous_categorie_seq', 11, true);


--
-- TOC entry 3182 (class 0 OID 0)
-- Dependencies: 208
-- Name: ville_id_ville_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ville_id_ville_seq', 6, true);


--
-- TOC entry 2963 (class 2606 OID 51376)
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (id_admin);


--
-- TOC entry 2965 (class 2606 OID 51466)
-- Name: categorie categorie_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorie
    ADD CONSTRAINT categorie_pkey PRIMARY KEY (id_categorie);


--
-- TOC entry 2975 (class 2606 OID 51536)
-- Name: client client_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (id_client);


--
-- TOC entry 2981 (class 2606 OID 51588)
-- Name: facture facture_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facture
    ADD CONSTRAINT facture_pkey PRIMARY KEY (id_facture);


--
-- TOC entry 2983 (class 2606 OID 51606)
-- Name: livraison livraison_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livraison
    ADD CONSTRAINT livraison_pkey PRIMARY KEY (id_livraison);


--
-- TOC entry 2973 (class 2606 OID 51520)
-- Name: magasin magasin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.magasin
    ADD CONSTRAINT magasin_pkey PRIMARY KEY (id_magasin);


--
-- TOC entry 2979 (class 2606 OID 51570)
-- Name: panier panier_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.panier
    ADD CONSTRAINT panier_pkey PRIMARY KEY (id_panier);


--
-- TOC entry 2969 (class 2606 OID 51493)
-- Name: pays pays_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pays
    ADD CONSTRAINT pays_pkey PRIMARY KEY (id_pays);


--
-- TOC entry 2977 (class 2606 OID 51552)
-- Name: produit produit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produit
    ADD CONSTRAINT produit_pkey PRIMARY KEY (id_produit);


--
-- TOC entry 2967 (class 2606 OID 51477)
-- Name: sous_categorie sous_categorie_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sous_categorie
    ADD CONSTRAINT sous_categorie_pkey PRIMARY KEY (id_sous_categorie);


--
-- TOC entry 2971 (class 2606 OID 51504)
-- Name: ville ville_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ville
    ADD CONSTRAINT ville_pkey PRIMARY KEY (id_ville);


--
-- TOC entry 2987 (class 2606 OID 51537)
-- Name: client client_id_ville_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_id_ville_fkey FOREIGN KEY (id_ville) REFERENCES public.ville(id_ville);


--
-- TOC entry 2993 (class 2606 OID 51594)
-- Name: facture facture_id_client_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facture
    ADD CONSTRAINT facture_id_client_fkey FOREIGN KEY (id_client) REFERENCES public.client(id_client);


--
-- TOC entry 2992 (class 2606 OID 51589)
-- Name: facture facture_id_produit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facture
    ADD CONSTRAINT facture_id_produit_fkey FOREIGN KEY (id_produit) REFERENCES public.produit(id_produit);


--
-- TOC entry 2995 (class 2606 OID 51612)
-- Name: livraison livraison_id_facture_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livraison
    ADD CONSTRAINT livraison_id_facture_fkey FOREIGN KEY (id_facture) REFERENCES public.facture(id_facture);


--
-- TOC entry 2994 (class 2606 OID 51607)
-- Name: livraison livraison_id_magasin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livraison
    ADD CONSTRAINT livraison_id_magasin_fkey FOREIGN KEY (id_magasin) REFERENCES public.magasin(id_magasin);


--
-- TOC entry 2986 (class 2606 OID 51521)
-- Name: magasin magasin_id_ville_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.magasin
    ADD CONSTRAINT magasin_id_ville_fkey FOREIGN KEY (id_ville) REFERENCES public.ville(id_ville);


--
-- TOC entry 2990 (class 2606 OID 51571)
-- Name: panier panier_id_client_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.panier
    ADD CONSTRAINT panier_id_client_fkey FOREIGN KEY (id_client) REFERENCES public.client(id_client);


--
-- TOC entry 2991 (class 2606 OID 51576)
-- Name: panier panier_id_produit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.panier
    ADD CONSTRAINT panier_id_produit_fkey FOREIGN KEY (id_produit) REFERENCES public.produit(id_produit);


--
-- TOC entry 2988 (class 2606 OID 51553)
-- Name: produit produit_id_magasin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produit
    ADD CONSTRAINT produit_id_magasin_fkey FOREIGN KEY (id_magasin) REFERENCES public.magasin(id_magasin);


--
-- TOC entry 2989 (class 2606 OID 51558)
-- Name: produit produit_id_sous_categorie_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produit
    ADD CONSTRAINT produit_id_sous_categorie_fkey FOREIGN KEY (id_sous_categorie) REFERENCES public.sous_categorie(id_sous_categorie);


--
-- TOC entry 2984 (class 2606 OID 51478)
-- Name: sous_categorie sous_categorie_id_categorie_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sous_categorie
    ADD CONSTRAINT sous_categorie_id_categorie_fkey FOREIGN KEY (id_categorie) REFERENCES public.categorie(id_categorie);


--
-- TOC entry 2985 (class 2606 OID 51505)
-- Name: ville ville_id_pays_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ville
    ADD CONSTRAINT ville_id_pays_fkey FOREIGN KEY (id_pays) REFERENCES public.pays(id_pays);


-- Completed on 2024-03-27 14:44:04

--
-- PostgreSQL database dump complete
--

