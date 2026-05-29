--
-- PostgreSQL database dump
--

\restrict OpAlhaNFRBTBfDi7ucgwkZ9y4hE9wJOoSR7yALIyDsIw1CEwR6FTwVNloGmzNQa

-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)

-- Started on 2026-05-29 19:36:25 EEST

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

DROP DATABASE "ComicDom";
--
-- TOC entry 3516 (class 1262 OID 16623)
-- Name: ComicDom; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "ComicDom" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_AU.UTF-8';


ALTER DATABASE "ComicDom" OWNER TO postgres;

\unrestrict OpAlhaNFRBTBfDi7ucgwkZ9y4hE9wJOoSR7yALIyDsIw1CEwR6FTwVNloGmzNQa
\connect "ComicDom"
\restrict OpAlhaNFRBTBfDi7ucgwkZ9y4hE9wJOoSR7yALIyDsIw1CEwR6FTwVNloGmzNQa

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
-- TOC entry 224 (class 1255 OID 16744)
-- Name: update_customer_spending(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_customer_spending() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
   artwork_price numeric(12,2);

begin

   -- find the price of the artwork
   select price
   into artwork_price
   from artwork
   where title = NEW.artwork_title;

   -- update the money_spent field
   update customer
   set money_spent = money_spent + artwork_price
   where name = NEW.customer_name;

   -- check sponsor
   if
   (
      select money_spent
      from customer
      where name = NEW.customer_name
   ) > 100000
   then
      insert into sponsor_tracker
      values
      (
         'SP' || NEW.purchase_id,
         NEW.customer_name,
         'Βαθμός 10',
         current_timestamp
      );
   end if;
   return NEW;
end;
$$;


ALTER FUNCTION public.update_customer_spending() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 16642)
-- Name: art_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.art_group (
    group_name character varying(100) NOT NULL
);


ALTER TABLE public.art_group OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16624)
-- Name: artist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.artist (
    name character varying(100) NOT NULL,
    birth_place character varying(100) NOT NULL,
    age integer NOT NULL,
    art_style character varying(100) NOT NULL,
    CONSTRAINT artist_age_check CHECK ((age > 0))
);


ALTER TABLE public.artist OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16630)
-- Name: artwork; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.artwork (
    title character varying(100) NOT NULL,
    creation_year integer NOT NULL,
    art_type character varying(100) NOT NULL,
    price numeric(12,2) NOT NULL,
    artist_name character varying(100) NOT NULL,
    CONSTRAINT artwork_creation_year_check CHECK ((creation_year > 0)),
    CONSTRAINT artwork_price_check CHECK ((price > (0)::numeric))
);


ALTER TABLE public.artwork OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16647)
-- Name: artwork_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.artwork_group (
    artwork_title character varying(100) NOT NULL,
    group_name character varying(100) NOT NULL
);


ALTER TABLE public.artwork_group OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16662)
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    name character varying(100) NOT NULL,
    address character varying(100) NOT NULL,
    money_spent numeric(12,2) DEFAULT 0 NOT NULL,
    email character varying(150),
    CONSTRAINT customer_money_spent_check CHECK ((money_spent >= (0)::numeric))
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16671)
-- Name: customer_prefers_artist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_prefers_artist (
    customer_name character varying(100) NOT NULL,
    artist_name character varying(100) NOT NULL
);


ALTER TABLE public.customer_prefers_artist OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16686)
-- Name: customer_prefers_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_prefers_group (
    customer_name character varying(100) NOT NULL,
    group_name character varying(100) NOT NULL
);


ALTER TABLE public.customer_prefers_group OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16701)
-- Name: purchase; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase (
    purchase_id character varying(20) NOT NULL,
    customer_name character varying(100) NOT NULL,
    artwork_title character varying(100) NOT NULL,
    purchase_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.purchase OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16719)
-- Name: sponsor_tracker; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sponsor_tracker (
    sponsor_id character varying(20) NOT NULL,
    customer_name character varying(100) NOT NULL,
    message text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sponsor_tracker OWNER TO postgres;

--
-- TOC entry 3504 (class 0 OID 16642)
-- Dependencies: 217
-- Data for Name: art_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.art_group (group_name) VALUES ('Portrait');
INSERT INTO public.art_group (group_name) VALUES ('Indie');
INSERT INTO public.art_group (group_name) VALUES ('Alternative');
INSERT INTO public.art_group (group_name) VALUES ('Bande Desinee');
INSERT INTO public.art_group (group_name) VALUES ('Superhero Comic');
INSERT INTO public.art_group (group_name) VALUES ('Manga');
INSERT INTO public.art_group (group_name) VALUES ('Manga Shonen');
INSERT INTO public.art_group (group_name) VALUES ('Manga Shojo');
INSERT INTO public.art_group (group_name) VALUES ('Manga Seinen');


--
-- TOC entry 3502 (class 0 OID 16624)
-- Dependencies: 215
-- Data for Name: artist; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Lynette McKennan', 'Tacna', 19, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Vi Berthot', 'Gerelayang', 50, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Nikolaos Clemenson', 'Cam Lâm', 48, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Pansie Loblie', 'Markham', 22, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Dianemarie Robilliard', 'Chamlykskaya', 98, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Alexei Kestin', 'Krajan', 54, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Erick Jacmard', 'Los Angeles', 100, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('El Fyldes', 'Wąwolnica', 26, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Fredek Wonter', 'Kulutan', 20, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Johnath Millthorpe', 'Tanay', 58, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Edan Grinnov', 'Baiheshan', 44, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Kelila Perocci', 'Jidong', 78, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Silvie Elgie', 'Puračić', 85, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Kesley Parfitt', 'Duraznopampa', 84, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Fancie Renish', 'Cergy-Pontoise', 91, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Salem Holston', 'Taradale', 33, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Hilary Sansam', 'Kasli', 56, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Mair Barclay', 'Dengfang', 60, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Amara Dowles', 'Zengfu', 45, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Revkah Clemencon', 'Jardinópolis', 46, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Hannie Stieger', 'Pameungpeuk', 69, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Jania Emig', 'Sumberkrajan', 19, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Rene Baylay', 'Pueblo Nuevo', 95, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Godart Obey', 'Śliwice', 79, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Curtis Treadway', 'Yong’an', 48, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Patty Lowis', 'Marseille', 79, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Fawn Burtt', 'Xiaoyangqi', 66, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Blayne Cobb', 'Jiangjing', 86, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Farrel O''Flannery', 'Novozybkov', 75, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Trever Martinon', '‘Afula ‘Illit', 90, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Perry De Lasci', 'Petrov', 97, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Robinia Nockells', 'Songying', 95, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Nickolaus Grigoli', 'Majan', 68, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Normand Pullar', 'Alcorriol', 70, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Corey Treker', 'Dowsk', 26, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Collin Pemberton', 'Sadabumi', 21, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Sydelle Renshell', 'Nonohonis', 60, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Kelila Cords', 'Sukarame', 79, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('De witt McClure', 'Dambarta', 51, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Darcy Brisley', 'Kokembang', 99, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Pall Tookill', 'Bolengpulau', 21, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Stefan Braunle', 'Shalazhi', 63, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Mikkel O'' Donohoe', 'General Conesa', 23, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Jeanelle Keymer', 'Taranovskoye', 18, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Benoite Eardley', 'Santa Ana', 46, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Horatia Keming', 'Dobje pri Planini', 51, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Franky Stagge', 'Makrochóri', 39, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Reginauld Dannatt', 'Ribeiro', 91, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Leandra Golton', 'Tékane', 44, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Annmarie Kment', 'Henggang', 75, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Mirabella Steer', 'Huipinggeng', 88, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Hobart Oppy', 'Arroyo Salado', 81, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Ezri Stockton', 'Cabedelo', 42, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Findlay Longwood', 'Shādegān', 23, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Deck Lauret', 'Ihuari', 93, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Carlynn Tether', 'Huangban', 32, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Zola Giottoi', 'Usagara', 53, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Noami Ryam', 'Lomintsevskiy', 40, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Dene Culross', 'Otjimbingwe', 90, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Drucie Cruse', 'Adjumani', 82, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Fredrika Grima', 'Nemours', 47, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Ermengarde Beggin', 'Tembladera', 24, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Solomon Nossent', 'Sentul', 57, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Mirabelle de Chastelain', 'Guanba', 38, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Laina Hamel', 'Peroguarda', 79, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Juliann Matyushenko', 'Gokwe', 24, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Bryon McAndrew', 'Aguachica', 54, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Lori Franchioni', 'Shawnee Mission', 58, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Terrel Stallon', 'Weibin', 26, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Giulia Takis', 'Orimattila', 32, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Tab Smickle', 'Tugu', 86, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Zara Umpleby', 'Libourne', 56, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Zackariah Diloway', 'Valence', 34, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Deck Give', 'Rabat', 46, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Nita Jepperson', 'Thiès Nones', 64, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Marcia Checketts', 'Orlovskiy', 19, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Lonnie Lamble', 'San Agustín Acasaguastlán', 100, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Mikkel O''Sherin', 'Daiyue', 98, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Natalee Lickess', 'Strängnäs', 82, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Edyth Vardey', 'Presidente Venceslau', 34, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Ruthann Possa', 'Metz', 93, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Briny Frizzell', 'Novyye Kuz’minki', 22, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Harwell Ovendale', 'Kulautuva', 55, 'Realism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Orly Gamil', 'Beauharnois', 36, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Alexa Scragg', 'Vierzon', 22, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Millicent Maulkin', 'Āsmār', 79, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Ofelia Duesbury', 'Satuek', 47, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Ruby Kienzle', 'Lewograran', 68, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Dick Simenet', 'Dobratice', 54, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Rianon Twigg', 'Jiangtun', 86, 'Fantasy');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Alissa Giorio', 'Nioro', 96, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Susanna Simms', 'Magtangol', 65, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Karlan Sidary', 'Nepomuceno', 52, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Rhodie Robins', 'Sidowayah Lor', 100, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Raynor Felkin', 'Hulutao', 44, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Jessey Swede', 'Mtsensk', 48, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Rutledge Blankau', 'União', 20, 'Abstract');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Hebert Simionescu', 'Ruukki', 30, 'Minimalism');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Rosmunda Springle', 'Ivatsevichy', 36, 'Noir');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Denys McCurdy', 'Suohe', 51, 'Cartoon');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Artist1', 'Tokyo, Japan', 35, 'Manga');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Artist2', 'Osaka, Japan', 42, 'Manga');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Artist3', 'Kyoto, Japan', 29, 'Comics');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Artist4', 'Seoul, South Korea', 38, 'Illustration');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Artist5', 'Paris, France', 45, 'Graphic Novel');
INSERT INTO public.artist (name, birth_place, age, art_style) VALUES ('Dionysis Savvatianos', 'Thessaloniki', 32, 'Noir');


--
-- TOC entry 3503 (class 0 OID 16630)
-- Dependencies: 216
-- Data for Name: artwork; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Clematis texensis Buckley', 1966, 'Graphic Novel', 3431.65, 'Lynette McKennan');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Vicia cracca L. ssp. tenuifolia (Roth) Gaudin', 1978, 'Animation', 914.88, 'Vi Berthot');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Amorpha californica Nutt. var. californica', 1986, 'Comic', 1747.18, 'Nikolaos Clemenson');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Ledum groenlandicum Oeder', 2012, 'Illustration', 3784.13, 'Pansie Loblie');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Lamium L.', 1960, 'Animation', 2005.89, 'Dianemarie Robilliard');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Cladonia subsetacea Robbins ex A. Evans', 1965, 'Comic', 3308.46, 'Alexei Kestin');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Ipomopsis pinnata (Cav.) V.E. Grant', 1971, 'Comic', 675.60, 'Erick Jacmard');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Populus tremuloides Michx.', 1966, 'Graphic Novel', 4575.99, 'El Fyldes');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Monardella villosa Benth. ssp. obispoensis (Hoover) Jokerst', 2009, 'Illustration', 1545.22, 'Fredek Wonter');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Tragopogon mirus Ownbey', 2023, 'Graphic Novel', 2388.72, 'Johnath Millthorpe');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Hypnum pallescens (Hedw.) P. Beauv. var. protuberans (Brid.) Austin', 1992, 'Illustration', 2455.86, 'Edan Grinnov');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Carex ovalis Goodenough', 1975, 'Illustration', 1896.81, 'Kelila Perocci');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Salix ×simulans Fernald (pro sp.)', 1989, 'Animation', 3913.93, 'Silvie Elgie');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Polygonatum biflorum (Walter) Elliott var. necopinum R. Ownbey', 2014, 'Graphic Novel', 2383.83, 'Kesley Parfitt');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Cyrtandra ×conradtii Rock (pro sp.)', 1958, 'Animation', 4001.00, 'Fancie Renish');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Calamagrostis stricta (Timm) Koeler ssp. stricta', 1986, 'Animation', 2392.96, 'Salem Holston');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Erigeron rybius G.L. Nesom', 1986, 'Comic', 2739.65, 'Hilary Sansam');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Nicotiana repanda Willd. ex Lehm.', 1955, 'Graphic Novel', 432.75, 'Mair Barclay');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Eriogonum nutans Torr. & A. Gray', 2018, 'Illustration', 4429.17, 'Amara Dowles');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Packera pseudaurea (Rydb.) W.A. Weber & Á. Löve var. flavula (Greene) D.K. Trock & T.M. Barkley', 2013, 'Comic', 1979.95, 'Revkah Clemencon');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Glycine tabacina (Labill.) Benth.', 1999, 'Animation', 4693.70, 'Hannie Stieger');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Trichostema brachiatum L.', 1951, 'Illustration', 26.68, 'Jania Emig');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Metroxylon sagu Rottb.', 1988, 'Comic', 4821.24, 'Rene Baylay');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Peltigera kristinssonii Vitik.', 1985, 'Comic', 1389.08, 'Godart Obey');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Penstemon absarokensis Evert', 1999, 'Graphic Novel', 825.21, 'Curtis Treadway');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Campylopus fragilis (Brid.) Bruch & Schimp.', 1986, 'Graphic Novel', 4328.63, 'Patty Lowis');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Myosurus apetalus C. Gay', 2007, 'Graphic Novel', 220.58, 'Fawn Burtt');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Penstemon leiophyllus Pennell var. leiophyllus', 2003, 'Graphic Novel', 4144.73, 'Blayne Cobb');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Lecidea leucothallina Arnold', 1976, 'Animation', 351.01, 'Farrel O''Flannery');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Pterogonium gracile (Hedw.) Sm.', 1984, 'Illustration', 2695.99, 'Trever Martinon');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Bryoria chalybeiformis (L.) Brodo & D. Hawksw.', 2008, 'Animation', 505.00, 'Perry De Lasci');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Chaenotheca cinerea (Pers.) Tibell', 1981, 'Graphic Novel', 4885.75, 'Robinia Nockells');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Didymodon tophaceus (Brid.) Lisa', 2019, 'Illustration', 3658.46, 'Nickolaus Grigoli');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Arabis oxylobula Greene', 1971, 'Graphic Novel', 1645.10, 'Normand Pullar');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Crataegus limata Beadle', 2022, 'Comic', 4025.14, 'Corey Treker');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Cardiospermum dissectum (S. Watson) Radlk.', 2009, 'Animation', 159.55, 'Collin Pemberton');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Polystichum acrostichoides (Michx.) Schott', 2004, 'Illustration', 1226.37, 'Sydelle Renshell');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Carex congdonii L.H. Bailey', 2022, 'Graphic Novel', 3141.33, 'Kelila Cords');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Abronia ameliae Lundell', 1975, 'Illustration', 1946.54, 'De witt McClure');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Pleurocoronis pluriseta (A. Gray) R.M. King & H. Rob.', 1975, 'Comic', 4354.38, 'Darcy Brisley');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Pinus contorta Douglas ex Loudon var. bolanderi (Parl.) Vasey', 1977, 'Animation', 531.05, 'Pall Tookill');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Coreopsis wrightii (A. Gray) H.M. Parker', 1982, 'Illustration', 3356.35, 'Stefan Braunle');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Picea A. Dietr.', 1955, 'Illustration', 2264.65, 'Mikkel O'' Donohoe');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Streptanthus carinatus C. Wright ex A. Gray', 2010, 'Illustration', 1051.18, 'Jeanelle Keymer');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Mitracarpus breviflorus A. Gray', 1998, 'Animation', 1220.00, 'Benoite Eardley');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Ranunculus lapponicus L.', 1965, 'Comic', 557.37, 'Horatia Keming');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Agropyron desertorum (Fisch. ex Link) Schult.', 1998, 'Illustration', 2229.83, 'Franky Stagge');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Diploicia A. Massal.', 1976, 'Animation', 4243.54, 'Reginauld Dannatt');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Spiraea tomentosa L.', 1998, 'Comic', 1534.79, 'Leandra Golton');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Cestrum parqui L''Hér.', 1971, 'Comic', 4249.21, 'Annmarie Kment');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Calochortus simulans (Hoover) Munz', 1953, 'Graphic Novel', 421.89, 'Mirabella Steer');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Thelesperma burridgeanum (Regel, Korn. & Rach.) S.F. Blake', 1953, 'Comic', 2104.51, 'Hobart Oppy');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Crossidium squamiferum (Viv.) Jur.', 1960, 'Comic', 471.71, 'Ezri Stockton');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Caperonia castaneifolia (L.) A. St.-Hil.', 1991, 'Animation', 1107.58, 'Findlay Longwood');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Callisia repens (Jacq.) L.', 1973, 'Animation', 1286.35, 'Deck Lauret');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Saponaria pumilio (L.) Fenzl ex A. Braun', 2020, 'Graphic Novel', 2438.72, 'Carlynn Tether');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Castilleja miniata Douglas ex Hook. ssp. dixonii (Fernald) Kartesz', 1971, 'Animation', 2913.85, 'Zola Giottoi');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Pyrenula macularis (Zahlbr.) R.C. Harris', 2017, 'Illustration', 4265.56, 'Noami Ryam');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Ericameria greenei (A. Gray) G.L. Nesom', 2006, 'Illustration', 1143.83, 'Dene Culross');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Euphorbia hexagona Nutt. ex Spreng.', 1959, 'Animation', 1584.69, 'Drucie Cruse');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Arenaria stenomeres Eastw.', 2010, 'Illustration', 3368.30, 'Fredrika Grima');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Solidago canadensis L. var. lepida (DC.) Cronquist', 1954, 'Illustration', 2547.28, 'Ermengarde Beggin');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Eucalyptus loxophleba Benth.', 2013, 'Animation', 3192.81, 'Solomon Nossent');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Rosa stellata Wooton ssp. abyssa A. Phillips', 1992, 'Illustration', 2038.92, 'Mirabelle de Chastelain');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Collinsia torreyi A. Gray var. wrightii (S. Watson) I.M. Johnst.', 1995, 'Animation', 451.45, 'Laina Hamel');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Malvella sagittifolia (A. Gray) Fryxell', 1979, 'Comic', 3558.69, 'Juliann Matyushenko');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Thelomma santessonii Tibell', 1967, 'Comic', 961.89, 'Bryon McAndrew');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Pentachaeta aurea Nutt. ssp. aurea', 1982, 'Animation', 3427.33, 'Lori Franchioni');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Fraxinus papillosa Lingelsh.', 1975, 'Graphic Novel', 594.83, 'Terrel Stallon');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Lewisia cotyledon (S. Watson) B.L. Rob. var. howellii (S. Watson) Jeps.', 2008, 'Graphic Novel', 2741.45, 'Giulia Takis');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Buxbaumia Hedw.', 1996, 'Illustration', 3481.25, 'Tab Smickle');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Parietaria officinalis L.', 1962, 'Graphic Novel', 1249.54, 'Zara Umpleby');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Laurera Rchb.', 1993, 'Graphic Novel', 3017.31, 'Zackariah Diloway');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Galium emeryense Dempster & Ehrend.', 1968, 'Animation', 4179.16, 'Deck Give');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Aquilegia jonesii Parry var. jonesii', 1956, 'Graphic Novel', 2187.05, 'Nita Jepperson');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Nephrolepis exaltata (L.) Schott ssp. exaltata', 1971, 'Comic', 1871.55, 'Marcia Checketts');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Arctostaphylos tomentosa (Pursh) Lindl. ssp. insulicola P.V. Wells', 1985, 'Illustration', 3427.22, 'Lonnie Lamble');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Chamaedorea seifrizii Burret', 1999, 'Illustration', 1107.33, 'Mikkel O''Sherin');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Coursetia DC.', 1969, 'Animation', 4126.07, 'Natalee Lickess');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Scorpidium (Schimp.) Limpr.', 2022, 'Graphic Novel', 3128.37, 'Edyth Vardey');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Pycnanthemum californicum Torr. ex Durand', 1986, 'Comic', 4966.99, 'Ruthann Possa');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Stuckenia filiformis (Pers.) Börner', 1958, 'Comic', 3063.55, 'Briny Frizzell');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Trifolium echinatum M. Bieb. var. echinatum', 1957, 'Animation', 1663.82, 'Harwell Ovendale');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Ranunculus andersonii A. Gray', 2000, 'Comic', 3290.60, 'Orly Gamil');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Protothelenella sphinctrinoides (Nyl.) H. Mayrh. & Poelt', 1977, 'Illustration', 4070.62, 'Alexa Scragg');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Campanula glomerata L.', 1982, 'Comic', 1770.36, 'Millicent Maulkin');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Alternanthera hassleriana Chodat ex Chodat & Hassler', 1993, 'Animation', 1139.81, 'Ofelia Duesbury');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Linaria spartea (L.) Chaz.', 1987, 'Graphic Novel', 446.29, 'Ruby Kienzle');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Rubus glaucifolius Kellogg var. glaucifolius', 2020, 'Comic', 3086.82, 'Dick Simenet');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Buglossoides arvensis (L.) I.M. Johnst.', 2003, 'Animation', 2980.34, 'Rianon Twigg');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Silphium laciniatum L. var. laciniatum', 2015, 'Animation', 3388.19, 'Alissa Giorio');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Packera spellenbergii (T.M. Barkley) C. Jeffrey', 2005, 'Comic', 3205.28, 'Susanna Simms');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Helenium ×polyphyllum Small (pro sp.)', 1975, 'Animation', 4016.52, 'Karlan Sidary');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Ivesia utahensis S. Watson', 2013, 'Comic', 61.75, 'Rhodie Robins');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Calamagrostis stricta (Timm) Koeler', 2018, 'Animation', 1282.47, 'Raynor Felkin');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Beta atriplicifolia Rouy', 1962, 'Graphic Novel', 4755.45, 'Jessey Swede');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Sphaerophorus globosus (Huds.) Vain. var. gracilis (Müll. Arg.) Zahlbr.', 1987, 'Animation', 2052.17, 'Rutledge Blankau');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Acacia macracantha Humb. & Bonpl. ex Willd.', 1968, 'Illustration', 60.52, 'Hebert Simionescu');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Polyblastia theleodes (Sommerf.) Th. Fr.', 2002, 'Animation', 739.02, 'Rosmunda Springle');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Passiflora suberosa L.', 1968, 'Comic', 2869.03, 'Denys McCurdy');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 1', 2024, 'comics', 25000.00, 'Artist1');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 2', 2023, 'comics', 18000.00, 'Artist2');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 3', 2025, 'comics', 22000.00, 'Artist3');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 4', 2024, 'comics', 15000.00, 'Artist4');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 5', 2023, 'comics', 20000.00, 'Artist5');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 6', 2024, 'comics', 25000.00, 'Artist1');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 7', 2023, 'comics', 18000.00, 'Artist2');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 8', 2024, 'comics', 15000.00, 'Artist4');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 9', 2025, 'comics', 22000.00, 'Artist3');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 10', 2023, 'comics', 20000.00, 'Artist5');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 11', 2024, 'comics', 17000.00, 'Artist1');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 12', 2024, 'comics', 19000.00, 'Artist2');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 13', 2025, 'comics', 21000.00, 'Artist3');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 14', 2023, 'comics', 23000.00, 'Artist4');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Manga Masterpiece 15', 2024, 'comics', 20000.00, 'Artist5');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Little tables outside', 1983, 'Comic', 15000.00, 'Dionysis Savvatianos');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Dirty bread', 1972, 'Animation', 20000.00, 'Dionysis Savvatianos');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('The haircut', 1989, 'Graphic Novel', 18000.00, 'Dionysis Savvatianos');
INSERT INTO public.artwork (title, creation_year, art_type, price, artist_name) VALUES ('Truck', 1966, 'Illustration', 12000.00, 'Dionysis Savvatianos');


--
-- TOC entry 3505 (class 0 OID 16647)
-- Dependencies: 218
-- Data for Name: artwork_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Clematis texensis Buckley', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Vicia cracca L. ssp. tenuifolia (Roth) Gaudin', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Amorpha californica Nutt. var. californica', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Ledum groenlandicum Oeder', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Lamium L.', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Cladonia subsetacea Robbins ex A. Evans', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Ipomopsis pinnata (Cav.) V.E. Grant', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Populus tremuloides Michx.', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Monardella villosa Benth. ssp. obispoensis (Hoover) Jokerst', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Tragopogon mirus Ownbey', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Hypnum pallescens (Hedw.) P. Beauv. var. protuberans (Brid.) Austin', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Carex ovalis Goodenough', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Salix ×simulans Fernald (pro sp.)', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Polygonatum biflorum (Walter) Elliott var. necopinum R. Ownbey', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Cyrtandra ×conradtii Rock (pro sp.)', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Calamagrostis stricta (Timm) Koeler ssp. stricta', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Erigeron rybius G.L. Nesom', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Nicotiana repanda Willd. ex Lehm.', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Eriogonum nutans Torr. & A. Gray', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Packera pseudaurea (Rydb.) W.A. Weber & Á. Löve var. flavula (Greene) D.K. Trock & T.M. Barkley', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Glycine tabacina (Labill.) Benth.', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Trichostema brachiatum L.', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Metroxylon sagu Rottb.', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Peltigera kristinssonii Vitik.', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Penstemon absarokensis Evert', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Campylopus fragilis (Brid.) Bruch & Schimp.', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Myosurus apetalus C. Gay', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Penstemon leiophyllus Pennell var. leiophyllus', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Lecidea leucothallina Arnold', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Pterogonium gracile (Hedw.) Sm.', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Bryoria chalybeiformis (L.) Brodo & D. Hawksw.', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Chaenotheca cinerea (Pers.) Tibell', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Didymodon tophaceus (Brid.) Lisa', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Arabis oxylobula Greene', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Crataegus limata Beadle', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Cardiospermum dissectum (S. Watson) Radlk.', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Polystichum acrostichoides (Michx.) Schott', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Carex congdonii L.H. Bailey', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Abronia ameliae Lundell', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Pleurocoronis pluriseta (A. Gray) R.M. King & H. Rob.', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Pinus contorta Douglas ex Loudon var. bolanderi (Parl.) Vasey', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Coreopsis wrightii (A. Gray) H.M. Parker', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Picea A. Dietr.', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Streptanthus carinatus C. Wright ex A. Gray', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Mitracarpus breviflorus A. Gray', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Ranunculus lapponicus L.', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Agropyron desertorum (Fisch. ex Link) Schult.', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Diploicia A. Massal.', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Spiraea tomentosa L.', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Cestrum parqui L''Hér.', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Calochortus simulans (Hoover) Munz', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Thelesperma burridgeanum (Regel, Korn. & Rach.) S.F. Blake', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Crossidium squamiferum (Viv.) Jur.', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Caperonia castaneifolia (L.) A. St.-Hil.', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Callisia repens (Jacq.) L.', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Saponaria pumilio (L.) Fenzl ex A. Braun', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Castilleja miniata Douglas ex Hook. ssp. dixonii (Fernald) Kartesz', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Pyrenula macularis (Zahlbr.) R.C. Harris', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Ericameria greenei (A. Gray) G.L. Nesom', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Euphorbia hexagona Nutt. ex Spreng.', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Arenaria stenomeres Eastw.', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Solidago canadensis L. var. lepida (DC.) Cronquist', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Eucalyptus loxophleba Benth.', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Rosa stellata Wooton ssp. abyssa A. Phillips', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Collinsia torreyi A. Gray var. wrightii (S. Watson) I.M. Johnst.', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Malvella sagittifolia (A. Gray) Fryxell', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Thelomma santessonii Tibell', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Pentachaeta aurea Nutt. ssp. aurea', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Fraxinus papillosa Lingelsh.', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Lewisia cotyledon (S. Watson) B.L. Rob. var. howellii (S. Watson) Jeps.', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Buxbaumia Hedw.', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Parietaria officinalis L.', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Laurera Rchb.', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Galium emeryense Dempster & Ehrend.', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Aquilegia jonesii Parry var. jonesii', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Nephrolepis exaltata (L.) Schott ssp. exaltata', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Arctostaphylos tomentosa (Pursh) Lindl. ssp. insulicola P.V. Wells', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Chamaedorea seifrizii Burret', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Coursetia DC.', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Scorpidium (Schimp.) Limpr.', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Pycnanthemum californicum Torr. ex Durand', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Stuckenia filiformis (Pers.) Börner', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Trifolium echinatum M. Bieb. var. echinatum', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Ranunculus andersonii A. Gray', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Protothelenella sphinctrinoides (Nyl.) H. Mayrh. & Poelt', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Campanula glomerata L.', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Alternanthera hassleriana Chodat ex Chodat & Hassler', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Linaria spartea (L.) Chaz.', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Rubus glaucifolius Kellogg var. glaucifolius', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Buglossoides arvensis (L.) I.M. Johnst.', 'Superhero Comic');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Silphium laciniatum L. var. laciniatum', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Packera spellenbergii (T.M. Barkley) C. Jeffrey', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Helenium ×polyphyllum Small (pro sp.)', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Ivesia utahensis S. Watson', 'Portrait');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Calamagrostis stricta (Timm) Koeler', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Beta atriplicifolia Rouy', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Sphaerophorus globosus (Huds.) Vain. var. gracilis (Müll. Arg.) Zahlbr.', 'Indie');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Acacia macracantha Humb. & Bonpl. ex Willd.', 'Bande Desinee');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Polyblastia theleodes (Sommerf.) Th. Fr.', 'Alternative');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Passiflora suberosa L.', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 6', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 6', 'Manga Shonen');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 7', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 8', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 9', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 9', 'Manga Seinen');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 10', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 11', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 12', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 12', 'Manga Shonen');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 13', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 14', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Manga Masterpiece 15', 'Manga');
INSERT INTO public.artwork_group (artwork_title, group_name) VALUES ('Dirty bread', 'Manga');


--
-- TOC entry 3506 (class 0 OID 16662)
-- Dependencies: 219
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Maria Kalatou', '234 Kanari', 58000.00, 'mariak@gmail.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Nikos Oikonomidis', '45 Miaouli', 59000.00, 'nickO@gmail.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Mikis Theodoridis', '912 Ermou', 83000.00, 'mickt@gmail.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Gusty Kimmons', '0049 Leroy Lane', 3431.65, 'gkimmons0@apple.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Sawyer MacKomb', '916 Cherokee Street', 914.88, 'smackomb1@angelfire.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Teddie Wordsworth', '4 Truax Road', 1747.18, 'twordsworth2@hc360.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Wernher McCaghan', '85 Merchant Park', 3784.13, 'wmccaghan3@webnode.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Sarajane Galliford', '622 Old Gate Pass', 2005.89, 'sgalliford4@sun.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Joelynn Bagworth', '27 Tennyson Trail', 3308.46, 'jbagworth5@bbb.org');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Sharia Spindler', '7 Norway Maple Pass', 675.60, 'sspindler6@umich.edu');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Cahra Garey', '5778 Judy Trail', 4575.99, 'cgarey7@blinklist.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Arluene Duesberry', '538 Larry Alley', 1545.22, 'aduesberry8@irs.gov');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Rosalinde Kenright', '68 Continental Crossing', 2388.72, 'rkenright9@usgs.gov');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Arlan Bosnell', '5 Chive Circle', 2455.86, 'abosnella@google.com.au');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Darryl Garth', '49731 Melby Parkway', 1896.81, 'dgarthb@imgur.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Margalit Waszczykowski', '795 Memorial Drive', 3913.93, 'mwaszczykowskic@domainmarket.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Regine Caukill', '6722 Washington Street', 2383.83, 'rcaukilld@ca.gov');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Godart Creus', '04827 Packers Way', 4001.00, 'gcreuse@cbc.ca');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Gertie Lagen', '0471 Northwestern Plaza', 2392.96, 'glagenf@cnet.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Emeline Snowman', '7 Toban Way', 2739.65, 'esnowmang@tripod.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Mabelle Seeler', '796 Sycamore Avenue', 432.75, 'mseelerh@digg.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Veronique McKay', '09 Donald Court', 4429.17, 'vmckayi@vkontakte.ru');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Elwira Roke', '2 Village Alley', 1979.95, 'erokej@google.fr');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Dorelle Ailward', '96 Tennessee Street', 4693.70, 'dailwardk@photobucket.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Phillip MacCome', '68041 Fulton Terrace', 26.68, 'pmaccomel@paypal.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Darius Gready', '4 Coleman Park', 4821.24, 'dgreadym@intel.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Annissa Gonnet', '9020 Lillian Terrace', 1389.08, 'agonnetn@facebook.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Meyer Sawfoot', '83 Quincy Drive', 825.21, 'msawfooto@npr.org');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Farrell Neiland', '7 Esch Trail', 4328.63, 'fneilandp@ocn.ne.jp');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Miguelita Haslum', '59 Onsgard Point', 220.58, 'mhaslumq@ehow.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Conchita Eitter', '98383 Dovetail Junction', 4144.73, 'ceitterr@taobao.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Dominica Comsty', '9640 Tennessee Avenue', 351.01, 'dcomstys@msn.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Terrie McKerton', '0 Westport Center', 2695.99, 'tmckertont@google.cn');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Mace Chase', '52 Lakeland Drive', 505.00, 'mchaseu@instagram.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Felicity Fanstone', '66 5th Point', 4885.75, 'ffanstonev@ted.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Gianina Grouse', '596 Talisman Place', 3658.46, 'ggrousew@so-net.ne.jp');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Eliot Robroe', '3206 Lakewood Gardens Alley', 1645.10, 'erobroex@vinaora.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Towny Garmston', '22 Eggendart Place', 4025.14, 'tgarmstony@mediafire.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Ray Kinmond', '057 Mayfield Trail', 159.55, 'rkinmondz@redcross.org');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Felike De Nisco', '62 Saint Paul Road', 1226.37, 'fde10@printfriendly.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Catriona Lovart', '910 Hauk Park', 3141.33, 'clovart11@trellian.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Giovanna Wardhaugh', '878 4th Way', 1946.54, 'gwardhaugh12@paypal.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Renell Assante', '47700 Sachtjen Road', 4354.38, 'rassante13@independent.co.uk');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Sheelagh Lavallin', '69 Lunder Place', 531.05, 'slavallin14@cocolog-nifty.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Britta Coldham', '95877 Colorado Trail', 3356.35, 'bcoldham15@liveinternet.ru');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Valerye Voules', '58 Maple Wood Way', 2264.65, 'vvoules16@phoca.cz');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Nedi Tammadge', '467 Kingsford Junction', 1051.18, 'ntammadge17@bandcamp.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Monika Upston', '13 Hovde Lane', 1220.00, 'mupston18@yelp.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Rochester Gopsill', '80 Pennsylvania Center', 557.37, 'rgopsill19@spiegel.de');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Alexandre Flicker', '34 Boyd Alley', 2229.83, 'aflicker1a@rediff.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Ardyce Trafford', '17278 Dottie Hill', 4243.54, 'atrafford1b@myspace.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Bambi Minett', '6 Northridge Way', 1534.79, 'bminett1c@fema.gov');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Viviyan Nowland', '5444 Jana Court', 4249.21, 'vnowland1d@exblog.jp');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Margie Bubb', '0774 Ludington Crossing', 421.89, 'mbubb1e@geocities.jp');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Lee Banting', '7003 Pennsylvania Hill', 2104.51, 'lbanting1f@tuttocitta.it');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Orion McEneny', '13 Derek Point', 471.71, 'omceneny1g@nba.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Emily Inman', '04 Daystar Drive', 1107.58, 'einman1h@gov.uk');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Danit Sparwell', '13311 Jana Pass', 1286.35, 'dsparwell1i@sogou.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Alic Cass', '6804 Chinook Trail', 2438.72, 'acass1j@jimdo.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Lindsey Osichev', '6064 Kim Lane', 2913.85, 'losichev1k@blogs.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Zabrina Dacke', '839 Nobel Street', 4265.56, 'zdacke1l@technorati.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Filia Stanbury', '31345 Meadow Vale Way', 1143.83, 'fstanbury1m@ask.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Morgan Ponten', '46542 Arkansas Junction', 1584.69, 'mponten1n@ifeng.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Nate Mainwaring', '4 Spohn Center', 3368.30, 'nmainwaring1o@reference.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Tedmund Mudge', '8054 Hayes Terrace', 2547.28, 'tmudge1p@washington.edu');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Thatcher Elletson', '79037 Maywood Street', 3192.81, 'telletson1q@theguardian.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Rem Fishburn', '78476 Arrowood Terrace', 2038.92, 'rfishburn1r@twitter.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Kingsly De Laci', '5 Sachtjen Road', 451.45, 'kde1s@scientificamerican.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Thadeus Laughton', '8 Rieder Pass', 3558.69, 'tlaughton1t@dion.ne.jp');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Katharina Officer', '42156 Talmadge Street', 961.89, 'kofficer1u@icio.us');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Klara Sloan', '2 Muir Way', 3427.33, 'ksloan1v@squidoo.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Giacomo Sabin', '621 Fieldstone Place', 594.83, 'gsabin1w@acquirethisname.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Dukie Oen', '73 Mitchell Road', 2741.45, 'doen1x@amazon.co.jp');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Madelene Binch', '837 Portage Avenue', 3481.25, 'mbinch1y@bloglines.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Charo Fairlie', '189 Aberg Alley', 1249.54, 'cfairlie1z@edublogs.org');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Kalina Filtness', '90815 Prairie Rose Point', 3017.31, 'kfiltness20@networkadvertising.org');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Barr Younge', '3 Waxwing Circle', 4179.16, 'byounge21@globo.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Shela Hallad', '00400 Ruskin Pass', 2187.05, 'shallad22@vk.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Maximo Bordes', '38483 Debra Point', 1871.55, 'mbordes23@istockphoto.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Emmye Bortol', '44 Sloan Drive', 3427.22, 'ebortol24@fotki.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Kevyn Birds', '72931 Karstens Park', 1107.33, 'kbirds25@surveymonkey.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Amos Shawyer', '885 Division Crossing', 4126.07, 'ashawyer26@examiner.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Romy Ianno', '7 Magdeline Court', 3128.37, 'rianno27@topsy.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Vincenz Kinsman', '87 Rowland Terrace', 4966.99, 'vkinsman28@alibaba.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Bryan Wolters', '4698 Eastwood Parkway', 3063.55, 'bwolters29@chicagotribune.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Levin Egle', '45809 Coleman Center', 1663.82, 'legle2a@pen.io');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Yasmeen Queyos', '327 Scoville Street', 3290.60, 'yqueyos2b@reverbnation.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Barbie Confait', '63 Del Mar Road', 4070.62, 'bconfait2c@plala.or.jp');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Blinni Spurden', '38788 Toban Way', 1770.36, 'bspurden2d@sina.com.cn');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Asia Biles', '32841 Farwell Pass', 1139.81, 'abiles2e@ihg.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Amberly Kayser', '68 Dixon Way', 446.29, 'akayser2f@ezinearticles.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Dur Oldmeadow', '9481 Saint Paul Point', 3086.82, 'doldmeadow2g@webeden.co.uk');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Lesli McGonigle', '97689 Kingsford Avenue', 2980.34, 'lmcgonigle2h@moonfruit.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Netta Purchon', '95220 Leroy Plaza', 3388.19, 'npurchon2i@theatlantic.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Augustine Done', '53 Carpenter Street', 3205.28, 'adone2j@yelp.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Virgina Sulter', '4 Harbort Junction', 4016.52, 'vsulter2k@facebook.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Cornie Grinsdale', '22548 Rieder Alley', 61.75, 'cgrinsdale2l@fda.gov');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Yvonne Dudson', '735 Melvin Trail', 1282.47, 'ydudson2m@booking.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Pepe Tiddy', '62 Northview Circle', 4755.45, 'ptiddy2n@java.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Whitman Riddall', '69309 Morrow Pass', 2052.17, 'wriddall2o@dmoz.org');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Norine Newlyn', '8 American Street', 60.52, 'nnewlyn2p@istockphoto.com');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Denna Margaret', '189 Weeping Birch Circle', 739.02, 'dmargaret2q@sina.com.cn');
INSERT INTO public.customer (name, address, money_spent, email) VALUES ('Ezra Swindell', '5 Service Trail', 2869.03, 'eswindell2r@telegraph.co.uk');


--
-- TOC entry 3507 (class 0 OID 16671)
-- Dependencies: 220
-- Data for Name: customer_prefers_artist; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Gusty Kimmons', 'Lynette McKennan');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Sawyer MacKomb', 'Vi Berthot');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Teddie Wordsworth', 'Nikolaos Clemenson');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Wernher McCaghan', 'Pansie Loblie');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Sarajane Galliford', 'Dianemarie Robilliard');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Joelynn Bagworth', 'Alexei Kestin');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Sharia Spindler', 'Erick Jacmard');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Cahra Garey', 'El Fyldes');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Arluene Duesberry', 'Fredek Wonter');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Rosalinde Kenright', 'Johnath Millthorpe');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Arlan Bosnell', 'Edan Grinnov');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Darryl Garth', 'Kelila Perocci');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Margalit Waszczykowski', 'Silvie Elgie');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Regine Caukill', 'Kesley Parfitt');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Godart Creus', 'Fancie Renish');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Gertie Lagen', 'Salem Holston');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Emeline Snowman', 'Hilary Sansam');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Mabelle Seeler', 'Mair Barclay');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Veronique McKay', 'Amara Dowles');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Elwira Roke', 'Revkah Clemencon');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Dorelle Ailward', 'Hannie Stieger');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Phillip MacCome', 'Jania Emig');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Darius Gready', 'Rene Baylay');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Annissa Gonnet', 'Godart Obey');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Meyer Sawfoot', 'Curtis Treadway');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Farrell Neiland', 'Patty Lowis');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Miguelita Haslum', 'Fawn Burtt');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Conchita Eitter', 'Blayne Cobb');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Dominica Comsty', 'Farrel O''Flannery');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Terrie McKerton', 'Trever Martinon');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Mace Chase', 'Perry De Lasci');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Felicity Fanstone', 'Robinia Nockells');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Gianina Grouse', 'Nickolaus Grigoli');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Eliot Robroe', 'Normand Pullar');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Towny Garmston', 'Corey Treker');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Ray Kinmond', 'Collin Pemberton');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Felike De Nisco', 'Sydelle Renshell');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Catriona Lovart', 'Kelila Cords');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Giovanna Wardhaugh', 'De witt McClure');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Renell Assante', 'Darcy Brisley');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Sheelagh Lavallin', 'Pall Tookill');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Britta Coldham', 'Stefan Braunle');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Valerye Voules', 'Mikkel O'' Donohoe');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Nedi Tammadge', 'Jeanelle Keymer');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Monika Upston', 'Benoite Eardley');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Rochester Gopsill', 'Horatia Keming');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Alexandre Flicker', 'Franky Stagge');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Ardyce Trafford', 'Reginauld Dannatt');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Bambi Minett', 'Leandra Golton');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Viviyan Nowland', 'Annmarie Kment');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Margie Bubb', 'Mirabella Steer');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Lee Banting', 'Hobart Oppy');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Orion McEneny', 'Ezri Stockton');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Emily Inman', 'Findlay Longwood');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Danit Sparwell', 'Deck Lauret');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Alic Cass', 'Carlynn Tether');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Lindsey Osichev', 'Zola Giottoi');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Zabrina Dacke', 'Noami Ryam');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Filia Stanbury', 'Dene Culross');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Morgan Ponten', 'Drucie Cruse');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Nate Mainwaring', 'Fredrika Grima');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Tedmund Mudge', 'Ermengarde Beggin');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Thatcher Elletson', 'Solomon Nossent');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Rem Fishburn', 'Mirabelle de Chastelain');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Kingsly De Laci', 'Laina Hamel');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Thadeus Laughton', 'Juliann Matyushenko');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Katharina Officer', 'Bryon McAndrew');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Klara Sloan', 'Lori Franchioni');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Giacomo Sabin', 'Terrel Stallon');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Dukie Oen', 'Giulia Takis');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Madelene Binch', 'Tab Smickle');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Charo Fairlie', 'Zara Umpleby');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Kalina Filtness', 'Zackariah Diloway');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Barr Younge', 'Deck Give');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Shela Hallad', 'Nita Jepperson');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Maximo Bordes', 'Marcia Checketts');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Emmye Bortol', 'Lonnie Lamble');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Kevyn Birds', 'Mikkel O''Sherin');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Amos Shawyer', 'Natalee Lickess');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Romy Ianno', 'Edyth Vardey');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Vincenz Kinsman', 'Ruthann Possa');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Bryan Wolters', 'Briny Frizzell');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Levin Egle', 'Harwell Ovendale');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Yasmeen Queyos', 'Orly Gamil');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Barbie Confait', 'Alexa Scragg');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Blinni Spurden', 'Millicent Maulkin');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Asia Biles', 'Ofelia Duesbury');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Amberly Kayser', 'Ruby Kienzle');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Dur Oldmeadow', 'Dick Simenet');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Lesli McGonigle', 'Rianon Twigg');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Netta Purchon', 'Alissa Giorio');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Augustine Done', 'Susanna Simms');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Virgina Sulter', 'Karlan Sidary');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Cornie Grinsdale', 'Rhodie Robins');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Yvonne Dudson', 'Raynor Felkin');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Pepe Tiddy', 'Jessey Swede');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Whitman Riddall', 'Rutledge Blankau');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Norine Newlyn', 'Hebert Simionescu');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Denna Margaret', 'Rosmunda Springle');
INSERT INTO public.customer_prefers_artist (customer_name, artist_name) VALUES ('Ezra Swindell', 'Denys McCurdy');


--
-- TOC entry 3508 (class 0 OID 16686)
-- Dependencies: 221
-- Data for Name: customer_prefers_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Gusty Kimmons', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Sawyer MacKomb', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Teddie Wordsworth', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Wernher McCaghan', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Sarajane Galliford', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Joelynn Bagworth', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Sharia Spindler', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Cahra Garey', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Arluene Duesberry', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Rosalinde Kenright', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Arlan Bosnell', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Darryl Garth', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Margalit Waszczykowski', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Regine Caukill', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Godart Creus', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Gertie Lagen', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Emeline Snowman', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Mabelle Seeler', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Veronique McKay', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Elwira Roke', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Dorelle Ailward', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Phillip MacCome', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Darius Gready', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Annissa Gonnet', 'Bande Desinee');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Meyer Sawfoot', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Farrell Neiland', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Miguelita Haslum', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Conchita Eitter', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Dominica Comsty', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Terrie McKerton', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Mace Chase', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Felicity Fanstone', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Gianina Grouse', 'Bande Desinee');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Eliot Robroe', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Towny Garmston', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Ray Kinmond', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Felike De Nisco', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Catriona Lovart', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Giovanna Wardhaugh', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Renell Assante', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Sheelagh Lavallin', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Britta Coldham', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Valerye Voules', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Nedi Tammadge', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Monika Upston', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Rochester Gopsill', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Alexandre Flicker', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Ardyce Trafford', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Bambi Minett', 'Bande Desinee');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Viviyan Nowland', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Margie Bubb', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Lee Banting', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Orion McEneny', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Emily Inman', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Danit Sparwell', 'Bande Desinee');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Alic Cass', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Lindsey Osichev', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Zabrina Dacke', 'Bande Desinee');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Filia Stanbury', 'Bande Desinee');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Morgan Ponten', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Nate Mainwaring', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Tedmund Mudge', 'Bande Desinee');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Thatcher Elletson', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Rem Fishburn', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Kingsly De Laci', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Thadeus Laughton', 'Bande Desinee');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Katharina Officer', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Klara Sloan', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Giacomo Sabin', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Dukie Oen', 'Bande Desinee');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Madelene Binch', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Charo Fairlie', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Kalina Filtness', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Barr Younge', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Shela Hallad', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Maximo Bordes', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Emmye Bortol', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Kevyn Birds', 'Bande Desinee');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Amos Shawyer', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Romy Ianno', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Vincenz Kinsman', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Bryan Wolters', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Levin Egle', 'Bande Desinee');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Yasmeen Queyos', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Barbie Confait', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Blinni Spurden', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Asia Biles', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Amberly Kayser', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Dur Oldmeadow', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Lesli McGonigle', 'Bande Desinee');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Netta Purchon', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Augustine Done', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Virgina Sulter', 'Indie');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Cornie Grinsdale', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Yvonne Dudson', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Pepe Tiddy', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Whitman Riddall', 'Portrait');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Norine Newlyn', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Denna Margaret', 'Superhero Comic');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Ezra Swindell', 'Alternative');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Maria Kalatou', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Maria Kalatou', 'Manga Shonen');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Maria Kalatou', 'Manga Seinen');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Maria Kalatou', 'Manga Shojo');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Nikos Oikonomidis', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Nikos Oikonomidis', 'Manga Shonen');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Nikos Oikonomidis', 'Manga Seinen');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Nikos Oikonomidis', 'Manga Shojo');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Mikis Theodoridis', 'Manga');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Mikis Theodoridis', 'Manga Shonen');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Mikis Theodoridis', 'Manga Seinen');
INSERT INTO public.customer_prefers_group (customer_name, group_name) VALUES ('Mikis Theodoridis', 'Manga Shojo');


--
-- TOC entry 3509 (class 0 OID 16701)
-- Dependencies: 222
-- Data for Name: purchase; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0001', 'Gusty Kimmons', 'Clematis texensis Buckley', '2026-05-29 10:03:12');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0042', 'Sawyer MacKomb', 'Vicia cracca L. ssp. tenuifolia (Roth) Gaudin', '2026-05-29 10:15:47');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0137', 'Teddie Wordsworth', 'Amorpha californica Nutt. var. californica', '2026-05-29 10:42:05');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0289', 'Wernher McCaghan', 'Ledum groenlandicum Oeder', '2026-05-29 11:08:33');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0364', 'Sarajane Galliford', 'Lamium L.', '2026-05-29 11:21:59');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0418', 'Joelynn Bagworth', 'Cladonia subsetacea Robbins ex A. Evans', '2026-05-29 11:45:10');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0527', 'Sharia Spindler', 'Ipomopsis pinnata (Cav.) V.E. Grant', '2026-05-29 12:02:44');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0613', 'Cahra Garey', 'Populus tremuloides Michx.', '2026-05-29 12:18:27');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0754', 'Arluene Duesberry', 'Monardella villosa Benth. ssp. obispoensis (Hoover) Jokerst', '2026-05-29 12:39:51');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0891', 'Rosalinde Kenright', 'Tragopogon mirus Ownbey', '2026-05-29 13:05:16');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P1023', 'Arlan Bosnell', 'Hypnum pallescens (Hedw.) P. Beauv. var. protuberans (Brid.) Austin', '2026-05-29 13:22:38');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P1145', 'Darryl Garth', 'Carex ovalis Goodenough', '2026-05-29 13:47:55');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P1267', 'Margalit Waszczykowski', 'Salix ×simulans Fernald (pro sp.)', '2026-05-29 14:03:29');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P1389', 'Regine Caukill', 'Polygonatum biflorum (Walter) Elliott var. necopinum R. Ownbey', '2026-05-29 14:26:11');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P1402', 'Godart Creus', 'Cyrtandra ×conradtii Rock (pro sp.)', '2026-05-29 14:49:02');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P1534', 'Gertie Lagen', 'Calamagrostis stricta (Timm) Koeler ssp. stricta', '2026-05-29 15:07:45');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P1678', 'Emeline Snowman', 'Erigeron rybius G.L. Nesom', '2026-05-29 15:31:18');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P1790', 'Mabelle Seeler', 'Nicotiana repanda Willd. ex Lehm.', '2026-05-29 15:52:40');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P1823', 'Veronique McKay', 'Eriogonum nutans Torr. & A. Gray', '2026-05-29 16:10:23');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P1956', 'Elwira Roke', 'Packera pseudaurea (Rydb.) W.A. Weber & Á. Löve var. flavula (Greene) D.K. Trock & T.M. Barkley', '2026-05-29 16:35:59');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P2014', 'Dorelle Ailward', 'Glycine tabacina (Labill.) Benth.', '2026-05-29 17:02:17');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P2138', 'Phillip MacCome', 'Trichostema brachiatum L.', '2026-05-29 17:19:43');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P2245', 'Darius Gready', 'Metroxylon sagu Rottb.', '2026-05-29 17:46:28');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P2367', 'Annissa Gonnet', 'Peltigera kristinssonii Vitik.', '2026-05-29 18:04:12');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P2489', 'Meyer Sawfoot', 'Penstemon absarokensis Evert', '2026-05-29 18:27:36');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P2501', 'Farrell Neiland', 'Campylopus fragilis (Brid.) Bruch & Schimp.', '2026-05-29 18:55:09');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P2634', 'Miguelita Haslum', 'Myosurus apetalus C. Gay', '2026-05-29 19:11:41');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P2756', 'Conchita Eitter', 'Penstemon leiophyllus Pennell var. leiophyllus', '2026-05-29 19:38:22');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P2878', 'Dominica Comsty', 'Lecidea leucothallina Arnold', '2026-05-29 19:57:58');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P2990', 'Terrie McKerton', 'Pterogonium gracile (Hedw.) Sm.', '2026-05-29 10:25:14');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P3012', 'Mace Chase', 'Bryoria chalybeiformis (L.) Brodo & D. Hawksw.', '2026-05-30 10:07:19');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P3134', 'Felicity Fanstone', 'Chaenotheca cinerea (Pers.) Tibell', '2026-05-30 10:33:48');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P3256', 'Gianina Grouse', 'Didymodon tophaceus (Brid.) Lisa', '2026-05-30 10:59:02');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P3378', 'Eliot Robroe', 'Arabis oxylobula Greene', '2026-05-30 11:14:27');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P3490', 'Towny Garmston', 'Crataegus limata Beadle', '2026-05-30 11:39:56');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P3512', 'Ray Kinmond', 'Cardiospermum dissectum (S. Watson) Radlk.', '2026-05-30 12:06:08');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P3634', 'Felike De Nisco', 'Polystichum acrostichoides (Michx.) Schott', '2026-05-30 12:21:33');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P3756', 'Catriona Lovart', 'Carex congdonii L.H. Bailey', '2026-05-30 12:48:17');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P3878', 'Giovanna Wardhaugh', 'Abronia ameliae Lundell', '2026-05-30 13:03:50');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P3990', 'Renell Assante', 'Pleurocoronis pluriseta (A. Gray) R.M. King & H. Rob.', '2026-05-30 13:29:11');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P4001', 'Sheelagh Lavallin', 'Pinus contorta Douglas ex Loudon var. bolanderi (Parl.) Vasey', '2026-05-30 13:52:42');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P4123', 'Britta Coldham', 'Coreopsis wrightii (A. Gray) H.M. Parker', '2026-05-30 14:10:09');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P4245', 'Valerye Voules', 'Picea A. Dietr.', '2026-05-30 14:35:23');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P4367', 'Nedi Tammadge', 'Streptanthus carinatus C. Wright ex A. Gray', '2026-05-30 14:57:38');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P4489', 'Monika Upston', 'Mitracarpus breviflorus A. Gray', '2026-05-30 15:13:26');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P4511', 'Rochester Gopsill', 'Ranunculus lapponicus L.', '2026-05-30 15:40:55');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P4633', 'Alexandre Flicker', 'Agropyron desertorum (Fisch. ex Link) Schult.', '2026-05-30 16:05:44');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P4755', 'Ardyce Trafford', 'Diploicia A. Massal.', '2026-05-30 16:28:31');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P4877', 'Bambi Minett', 'Spiraea tomentosa L.', '2026-05-30 16:47:12');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P4999', 'Viviyan Nowland', 'Cestrum parqui L''Hér.', '2026-05-30 17:09:58');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P5021', 'Margie Bubb', 'Calochortus simulans (Hoover) Munz', '2026-05-30 17:34:20');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P5143', 'Lee Banting', 'Thelesperma burridgeanum (Regel, Korn. & Rach.) S.F. Blake', '2026-05-30 17:58:41');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P5265', 'Orion McEneny', 'Crossidium squamiferum (Viv.) Jur.', '2026-05-30 18:16:07');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P5387', 'Emily Inman', 'Caperonia castaneifolia (L.) A. St.-Hil.', '2026-05-30 18:42:36');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P5409', 'Danit Sparwell', 'Callisia repens (Jacq.) L.', '2026-05-30 19:05:19');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P5531', 'Alic Cass', 'Saponaria pumilio (L.) Fenzl ex A. Braun', '2026-05-30 19:29:54');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P5653', 'Lindsey Osichev', 'Castilleja miniata Douglas ex Hook. ssp. dixonii (Fernald) Kartesz', '2026-05-30 19:50:12');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P5775', 'Zabrina Dacke', 'Pyrenula macularis (Zahlbr.) R.C. Harris', '2026-05-30 10:18:36');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P5897', 'Filia Stanbury', 'Ericameria greenei (A. Gray) G.L. Nesom', '2026-05-30 11:01:55');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P5919', 'Morgan Ponten', 'Euphorbia hexagona Nutt. ex Spreng.', '2026-05-31 10:04:44');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P6031', 'Nate Mainwaring', 'Arenaria stenomeres Eastw.', '2026-05-31 10:28:15');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P6153', 'Tedmund Mudge', 'Solidago canadensis L. var. lepida (DC.) Cronquist', '2026-05-31 10:51:37');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P6275', 'Thatcher Elletson', 'Eucalyptus loxophleba Benth.', '2026-05-31 11:16:09');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P6397', 'Rem Fishburn', 'Rosa stellata Wooton ssp. abyssa A. Phillips', '2026-05-31 11:42:30');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P6419', 'Kingsly De Laci', 'Collinsia torreyi A. Gray var. wrightii (S. Watson) I.M. Johnst.', '2026-05-31 12:03:11');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P6541', 'Thadeus Laughton', 'Malvella sagittifolia (A. Gray) Fryxell', '2026-05-31 12:25:47');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P6663', 'Katharina Officer', 'Thelomma santessonii Tibell', '2026-05-31 12:49:58');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P6785', 'Klara Sloan', 'Pentachaeta aurea Nutt. ssp. aurea', '2026-05-31 13:07:26');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P6807', 'Giacomo Sabin', 'Fraxinus papillosa Lingelsh.', '2026-05-31 13:31:53');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P6929', 'Dukie Oen', 'Lewisia cotyledon (S. Watson) B.L. Rob. var. howellii (S. Watson) Jeps.', '2026-05-31 13:55:14');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P7041', 'Madelene Binch', 'Buxbaumia Hedw.', '2026-05-31 14:12:38');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P7163', 'Charo Fairlie', 'Parietaria officinalis L.', '2026-05-31 14:37:05');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P7285', 'Kalina Filtness', 'Laurera Rchb.', '2026-05-31 15:02:41');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P7307', 'Barr Younge', 'Galium emeryense Dempster & Ehrend.', '2026-05-31 15:24:19');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P7429', 'Shela Hallad', 'Aquilegia jonesii Parry var. jonesii', '2026-05-31 15:48:52');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P7551', 'Maximo Bordes', 'Nephrolepis exaltata (L.) Schott ssp. exaltata', '2026-05-31 16:06:13');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P7673', 'Emmye Bortol', 'Arctostaphylos tomentosa (Pursh) Lindl. ssp. insulicola P.V. Wells', '2026-05-31 16:32:40');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P7795', 'Kevyn Birds', 'Chamaedorea seifrizii Burret', '2026-05-31 16:58:03');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P7817', 'Amos Shawyer', 'Coursetia DC.', '2026-05-31 17:15:29');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P7939', 'Romy Ianno', 'Scorpidium (Schimp.) Limpr.', '2026-05-31 17:39:51');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P8051', 'Vincenz Kinsman', 'Pycnanthemum californicum Torr. ex Durand', '2026-05-31 18:01:17');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P8173', 'Bryan Wolters', 'Stuckenia filiformis (Pers.) Börner', '2026-05-31 18:26:45');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P8295', 'Levin Egle', 'Trifolium echinatum M. Bieb. var. echinatum', '2026-05-31 18:49:08');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P8317', 'Yasmeen Queyos', 'Ranunculus andersonii A. Gray', '2026-05-31 19:13:36');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P8439', 'Barbie Confait', 'Protothelenella sphinctrinoides (Nyl.) H. Mayrh. & Poelt', '2026-05-31 19:37:22');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P8561', 'Blinni Spurden', 'Campanula glomerata L.', '2026-05-31 19:59:59');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P8683', 'Asia Biles', 'Alternanthera hassleriana Chodat ex Chodat & Hassler', '2026-05-31 10:21:10');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P8705', 'Amberly Kayser', 'Linaria spartea (L.) Chaz.', '2026-05-31 11:08:44');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P8827', 'Dur Oldmeadow', 'Rubus glaucifolius Kellogg var. glaucifolius', '2026-05-31 12:14:33');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P8949', 'Lesli McGonigle', 'Buglossoides arvensis (L.) I.M. Johnst.', '2026-05-31 13:22:57');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P9061', 'Netta Purchon', 'Silphium laciniatum L. var. laciniatum', '2026-05-31 14:18:49');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P9183', 'Augustine Done', 'Packera spellenbergii (T.M. Barkley) C. Jeffrey', '2026-05-31 15:36:12');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P9205', 'Virgina Sulter', 'Helenium ×polyphyllum Small (pro sp.)', '2026-05-31 16:44:28');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P9327', 'Cornie Grinsdale', 'Ivesia utahensis S. Watson', '2026-05-31 17:52:09');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P9449', 'Yvonne Dudson', 'Calamagrostis stricta (Timm) Koeler', '2026-05-31 18:33:55');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P9571', 'Pepe Tiddy', 'Beta atriplicifolia Rouy', '2026-05-31 19:46:18');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P9693', 'Whitman Riddall', 'Sphaerophorus globosus (Huds.) Vain. var. gracilis (Müll. Arg.) Zahlbr.', '2026-05-29 10:03:12');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P9715', 'Norine Newlyn', 'Acacia macracantha Humb. & Bonpl. ex Willd.', '2026-05-29 10:15:47');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P9837', 'Denna Margaret', 'Polyblastia theleodes (Sommerf.) Th. Fr.', '2026-05-29 10:42:05');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P9999', 'Ezra Swindell', 'Passiflora suberosa L.', '2026-05-29 11:08:33');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0002', 'Maria Kalatou', 'Manga Masterpiece 6', '2026-05-29 18:38:57.766389');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0003', 'Maria Kalatou', 'Manga Masterpiece 7', '2026-05-29 18:38:57.766389');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0004', 'Maria Kalatou', 'Manga Masterpiece 8', '2026-05-29 18:38:57.766389');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0005', 'Nikos Oikonomidis', 'Manga Masterpiece 9', '2026-05-29 18:38:57.766389');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0006', 'Nikos Oikonomidis', 'Manga Masterpiece 10', '2026-05-29 18:38:57.766389');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0007', 'Nikos Oikonomidis', 'Manga Masterpiece 11', '2026-05-29 18:38:57.766389');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0008', 'Mikis Theodoridis', 'Manga Masterpiece 12', '2026-05-29 18:38:57.766389');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0009', 'Mikis Theodoridis', 'Manga Masterpiece 13', '2026-05-29 18:38:57.766389');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0010', 'Mikis Theodoridis', 'Manga Masterpiece 14', '2026-05-29 18:38:57.766389');
INSERT INTO public.purchase (purchase_id, customer_name, artwork_title, purchase_date) VALUES ('P0011', 'Mikis Theodoridis', 'Manga Masterpiece 15', '2026-05-29 18:38:57.766389');


--
-- TOC entry 3510 (class 0 OID 16719)
-- Dependencies: 223
-- Data for Name: sponsor_tracker; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S0002', 'Gusty Kimmons', 'Bravo', '2026-05-29 10:01:03');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S0015', 'Sawyer MacKomb', 'Congrats', '2026-05-29 10:09:27');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S0234', 'Teddie Wordsworth', 'Gold Star', '2026-05-29 10:12:46');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S0456', 'Wernher McCaghan', 'Bravo', '2026-05-29 10:20:55');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S0678', 'Sarajane Galliford', 'Congrats', '2026-05-29 10:34:18');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S0890', 'Joelynn Bagworth', 'Kudos', '2026-05-29 10:46:05');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S1024', 'Sharia Spindler', 'Bravo', '2026-05-29 11:00:31');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S1187', 'Cahra Garey', 'Kudos', '2026-05-29 11:07:22');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S1309', 'Arluene Duesberry', 'Congrats', '2026-05-29 11:29:59');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S1492', 'Rosalinde Kenright', 'Gold Star', '2026-05-29 11:36:44');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S1586', 'Arlan Bosnell', 'Congrats', '2026-05-29 11:50:12');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S1674', 'Darryl Garth', 'Kudos', '2026-05-29 12:11:03');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S1798', 'Margalit Waszczykowski', 'Bravo', '2026-05-29 12:27:46');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S1820', 'Regine Caukill', 'Bravo', '2026-05-29 12:33:58');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S1945', 'Godart Creus', 'Kudos', '2026-05-29 12:47:21');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S2037', 'Gertie Lagen', 'Bravo', '2026-05-29 13:02:04');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S2199', 'Emeline Snowman', 'Bravo', '2026-05-29 13:15:39');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S2288', 'Mabelle Seeler', 'Bravo', '2026-05-29 13:28:07');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S2376', 'Veronique McKay', 'Gold Star', '2026-05-29 13:39:50');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S2491', 'Elwira Roke', 'Bravo', '2026-05-29 13:58:15');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S2543', 'Dorelle Ailward', 'Kudos', '2026-05-29 14:12:02');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S2667', 'Phillip MacCome', 'Kudos', '2026-05-29 14:18:47');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S2789', 'Darius Gready', 'Kudos', '2026-05-29 14:31:30');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S2801', 'Annissa Gonnet', 'Kudos', '2026-05-29 14:53:11');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S2935', 'Meyer Sawfoot', 'Kudos', '2026-05-29 15:09:29');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S3057', 'Farrell Neiland', 'Kudos', '2026-05-29 15:20:56');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S3179', 'Miguelita Haslum', 'Kudos', '2026-05-29 15:44:03');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S3290', 'Conchita Eitter', 'Kudos', '2026-05-29 15:58:46');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S3312', 'Dominica Comsty', 'Bravo', '2026-05-29 16:09:12');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S3446', 'Terrie McKerton', 'Bravo', '2026-05-29 16:21:39');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S3568', 'Mace Chase', 'Kudos', '2026-05-29 16:44:50');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S3680', 'Felicity Fanstone', 'Gold Star', '2026-05-29 16:57:31');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S3792', 'Gianina Grouse', 'Gold Star', '2026-05-29 17:08:05');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S3814', 'Eliot Robroe', 'Kudos', '2026-05-29 17:23:58');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S3957', 'Towny Garmston', 'Congrats', '2026-05-29 17:35:20');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S4079', 'Ray Kinmond', 'Kudos', '2026-05-29 17:48:07');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S4191', 'Felike De Nisco', 'Kudos', '2026-05-29 18:11:54');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S4203', 'Catriona Lovart', 'Bravo', '2026-05-29 18:22:31');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S4345', 'Giovanna Wardhaugh', 'Gold Star', '2026-05-29 18:39:16');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S4467', 'Renell Assante', 'Kudos', '2026-05-29 18:51:03');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S4589', 'Sheelagh Lavallin', 'Gold Star', '2026-05-29 19:03:28');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S4601', 'Britta Coldham', 'Kudos', '2026-05-29 19:15:59');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S4733', 'Valerye Voules', 'Congrats', '2026-05-29 19:27:44');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S4855', 'Nedi Tammadge', 'Kudos', '2026-05-29 19:41:10');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S4977', 'Monika Upston', 'Gold Star', '2026-05-29 19:52:33');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S5009', 'Rochester Gopsill', 'Gold Star', '2026-05-30 10:02:27');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S5121', 'Alexandre Flicker', 'Kudos', '2026-05-30 10:11:49');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S5243', 'Ardyce Trafford', 'Kudos', '2026-05-30 10:24:36');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S5365', 'Bambi Minett', 'Congrats', '2026-05-30 10:37:05');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S5487', 'Viviyan Nowland', 'Gold Star', '2026-05-30 10:45:18');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S5509', 'Margie Bubb', 'Kudos', '2026-05-30 10:53:47');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S5631', 'Lee Banting', 'Bravo', '2026-05-30 11:06:12');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S5753', 'Orion McEneny', 'Bravo', '2026-05-30 11:18:39');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S5875', 'Emily Inman', 'Kudos', '2026-05-30 11:27:55');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S5997', 'Danit Sparwell', 'Kudos', '2026-05-30 11:41:06');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S6019', 'Alic Cass', 'Kudos', '2026-05-30 11:55:34');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S6141', 'Lindsey Osichev', 'Congrats', '2026-05-30 12:08:47');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S6263', 'Zabrina Dacke', 'Congrats', '2026-05-30 12:19:13');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S6385', 'Filia Stanbury', 'Bravo', '2026-05-30 12:31:58');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S6407', 'Morgan Ponten', 'Gold Star', '2026-05-30 12:44:22');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S6529', 'Nate Mainwaring', 'Kudos', '2026-05-30 12:59:09');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S6651', 'Tedmund Mudge', 'Bravo', '2026-05-30 13:12:46');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S6773', 'Thatcher Elletson', 'Congrats', '2026-05-30 13:25:33');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S6895', 'Rem Fishburn', 'Congrats', '2026-05-30 13:38:07');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S6917', 'Kingsly De Laci', 'Bravo', '2026-05-30 13:50:58');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S7049', 'Thadeus Laughton', 'Bravo', '2026-05-30 14:06:21');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S7161', 'Katharina Officer', 'Kudos', '2026-05-30 14:18:04');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S7283', 'Klara Sloan', 'Congrats', '2026-05-30 14:29:56');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S7305', 'Giacomo Sabin', 'Kudos', '2026-05-30 14:43:12');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S7427', 'Dukie Oen', 'Gold Star', '2026-05-30 15:00:38');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S7549', 'Madelene Binch', 'Congrats', '2026-05-30 15:12:27');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S7671', 'Charo Fairlie', 'Gold Star', '2026-05-30 15:25:54');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S7793', 'Kalina Filtness', 'Kudos', '2026-05-30 15:39:05');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S7815', 'Barr Younge', 'Kudos', '2026-05-30 15:51:48');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S7937', 'Shela Hallad', 'Kudos', '2026-05-30 16:05:22');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S8059', 'Maximo Bordes', 'Kudos', '2026-05-30 16:18:09');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S8181', 'Emmye Bortol', 'Bravo', '2026-05-30 16:30:41');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S8203', 'Kevyn Birds', 'Gold Star', '2026-05-30 16:43:55');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S8325', 'Amos Shawyer', 'Kudos', '2026-05-30 16:58:12');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S8447', 'Romy Ianno', 'Gold Star', '2026-05-30 17:10:37');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S8569', 'Vincenz Kinsman', 'Kudos', '2026-05-30 17:23:58');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S8691', 'Bryan Wolters', 'Bravo', '2026-05-30 17:36:22');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S8713', 'Levin Egle', 'Bravo', '2026-05-30 17:49:49');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S8835', 'Yasmeen Queyos', 'Gold Star', '2026-05-30 18:02:16');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S8957', 'Barbie Confait', 'Bravo', '2026-05-30 18:15:33');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S9079', 'Blinni Spurden', 'Kudos', '2026-05-30 18:29:04');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S9101', 'Asia Biles', 'Congrats', '2026-05-30 18:41:41');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S9223', 'Amberly Kayser', 'Congrats', '2026-05-30 18:55:26');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S9345', 'Dur Oldmeadow', 'Congrats', '2026-05-30 19:06:58');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S9467', 'Lesli McGonigle', 'Kudos', '2026-05-30 19:19:13');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S9589', 'Netta Purchon', 'Bravo', '2026-05-30 19:31:45');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S9601', 'Augustine Done', 'Gold Star', '2026-05-30 19:44:52');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S9723', 'Virgina Sulter', 'Kudos', '2026-05-31 10:03:55');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S9845', 'Cornie Grinsdale', 'Gold Star', '2026-05-31 10:14:20');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S9967', 'Yvonne Dudson', 'Bravo', '2026-05-31 10:26:33');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S9989', 'Pepe Tiddy', 'Bravo', '2026-05-31 10:38:09');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S9998', 'Whitman Riddall', 'Congrats', '2026-05-31 10:50:47');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S1234', 'Norine Newlyn', 'Gold Star', '2026-05-31 11:03:21');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S4321', 'Denna Margaret', 'Kudos', '2026-05-31 11:15:58');
INSERT INTO public.sponsor_tracker (sponsor_id, customer_name, message, created_at) VALUES ('S2468', 'Ezra Swindell', 'Bravo', '2026-05-31 11:28:44');


--
-- TOC entry 3331 (class 2606 OID 16646)
-- Name: art_group art_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.art_group
    ADD CONSTRAINT art_group_pkey PRIMARY KEY (group_name);


--
-- TOC entry 3327 (class 2606 OID 16629)
-- Name: artist artist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artist
    ADD CONSTRAINT artist_pkey PRIMARY KEY (name);


--
-- TOC entry 3333 (class 2606 OID 16651)
-- Name: artwork_group artwork_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artwork_group
    ADD CONSTRAINT artwork_group_pkey PRIMARY KEY (artwork_title, group_name);


--
-- TOC entry 3329 (class 2606 OID 16636)
-- Name: artwork artwork_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artwork
    ADD CONSTRAINT artwork_pkey PRIMARY KEY (title);


--
-- TOC entry 3335 (class 2606 OID 16670)
-- Name: customer customer_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_email_key UNIQUE (email);


--
-- TOC entry 3337 (class 2606 OID 16668)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (name);


--
-- TOC entry 3339 (class 2606 OID 16675)
-- Name: customer_prefers_artist customer_prefers_artist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_prefers_artist
    ADD CONSTRAINT customer_prefers_artist_pkey PRIMARY KEY (customer_name, artist_name);


--
-- TOC entry 3341 (class 2606 OID 16690)
-- Name: customer_prefers_group customer_prefers_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_prefers_group
    ADD CONSTRAINT customer_prefers_group_pkey PRIMARY KEY (customer_name, group_name);


--
-- TOC entry 3343 (class 2606 OID 16708)
-- Name: purchase purchase_artwork_title_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT purchase_artwork_title_key UNIQUE (artwork_title);


--
-- TOC entry 3345 (class 2606 OID 16706)
-- Name: purchase purchase_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT purchase_pkey PRIMARY KEY (purchase_id);


--
-- TOC entry 3347 (class 2606 OID 16726)
-- Name: sponsor_tracker sponsor_tracker_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsor_tracker
    ADD CONSTRAINT sponsor_tracker_pkey PRIMARY KEY (sponsor_id);


--
-- TOC entry 3358 (class 2620 OID 16745)
-- Name: purchase trigger_update_customer_spending; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_customer_spending AFTER INSERT ON public.purchase FOR EACH ROW EXECUTE FUNCTION public.update_customer_spending();


--
-- TOC entry 3348 (class 2606 OID 16637)
-- Name: artwork artwork_artist_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artwork
    ADD CONSTRAINT artwork_artist_name_fkey FOREIGN KEY (artist_name) REFERENCES public.artist(name) ON DELETE RESTRICT;


--
-- TOC entry 3349 (class 2606 OID 16652)
-- Name: artwork_group artwork_group_artwork_title_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artwork_group
    ADD CONSTRAINT artwork_group_artwork_title_fkey FOREIGN KEY (artwork_title) REFERENCES public.artwork(title) ON DELETE RESTRICT;


--
-- TOC entry 3350 (class 2606 OID 16657)
-- Name: artwork_group artwork_group_group_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artwork_group
    ADD CONSTRAINT artwork_group_group_name_fkey FOREIGN KEY (group_name) REFERENCES public.art_group(group_name) ON DELETE RESTRICT;


--
-- TOC entry 3351 (class 2606 OID 16681)
-- Name: customer_prefers_artist customer_prefers_artist_artist_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_prefers_artist
    ADD CONSTRAINT customer_prefers_artist_artist_name_fkey FOREIGN KEY (artist_name) REFERENCES public.artist(name) ON DELETE CASCADE;


--
-- TOC entry 3352 (class 2606 OID 16676)
-- Name: customer_prefers_artist customer_prefers_artist_customer_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_prefers_artist
    ADD CONSTRAINT customer_prefers_artist_customer_name_fkey FOREIGN KEY (customer_name) REFERENCES public.customer(name) ON DELETE CASCADE;


--
-- TOC entry 3353 (class 2606 OID 16691)
-- Name: customer_prefers_group customer_prefers_group_customer_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_prefers_group
    ADD CONSTRAINT customer_prefers_group_customer_name_fkey FOREIGN KEY (customer_name) REFERENCES public.customer(name) ON DELETE CASCADE;


--
-- TOC entry 3354 (class 2606 OID 16696)
-- Name: customer_prefers_group customer_prefers_group_group_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_prefers_group
    ADD CONSTRAINT customer_prefers_group_group_name_fkey FOREIGN KEY (group_name) REFERENCES public.art_group(group_name) ON DELETE CASCADE;


--
-- TOC entry 3355 (class 2606 OID 16714)
-- Name: purchase purchase_artwork_title_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT purchase_artwork_title_fkey FOREIGN KEY (artwork_title) REFERENCES public.artwork(title);


--
-- TOC entry 3356 (class 2606 OID 16709)
-- Name: purchase purchase_customer_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT purchase_customer_name_fkey FOREIGN KEY (customer_name) REFERENCES public.customer(name);


--
-- TOC entry 3357 (class 2606 OID 16727)
-- Name: sponsor_tracker sponsor_tracker_customer_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsor_tracker
    ADD CONSTRAINT sponsor_tracker_customer_name_fkey FOREIGN KEY (customer_name) REFERENCES public.customer(name) ON DELETE RESTRICT;


-- Completed on 2026-05-29 19:36:25 EEST

--
-- PostgreSQL database dump complete
--

\unrestrict OpAlhaNFRBTBfDi7ucgwkZ9y4hE9wJOoSR7yALIyDsIw1CEwR6FTwVNloGmzNQa

