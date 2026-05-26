-- Database: ComicDom

-- DROP DATABASE IF EXISTS "ComicDom";

CREATE DATABASE "ComicDom"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

	--creation of the tables

--create artists table 
	create table if not exists ARTIST
	(
      name        varchar(100),
	  birth_place varchar(100) not null,
	  age         integer check(age>0 ) not null,
	  art_style   varchar(100) not null,
	  primary key (name)	  
	);

--creation artwork table 

    create table if not exists ARTWORK
	(
	 title         varchar(100),
	 creation_year integer  check(creation_year >0) not null,
	 art_type      varchar(100) not null,
	 price         numeric(12,2)  check(price>0)  not null,
	 artist_name   varchar(100)  not null,
	 primary key(title),
	 foreign key(artist_name) references ARTIST(name) 
	 on delete restrict   
	);

--creation of artgroup table
    create table if not exists ART_GROUP
	(
	 group_name varchar(100),
	 primary key(group_name)
	);


--creation of artworkgroup table
   create table if not exists ARTWORK_GROUP
   (
    artwork_title varchar(100),
	group_name    varchar(100),
	primary key(artwork_title,group_name),
	foreign key(artwork_title) references ARTWORK(title)
	on delete restrict,
	foreign key(group_name) references ART_GROUP(group_name)
	on delete restrict
   );

--creation of customer table
  create table if not exists CUSTOMER
  (
   name         varchar(100),
   address      varchar(100)    not null,
   money_spent  numeric(12,2)  check(money_spent>=0)  default 0 not null,
   email        varchar(150) unique,
   primary key(name)
  );

--creation of customer  preferences
  create table if not exists CUSTOMER_PREFERS_ARTIST
  (
   customer_name  varchar(100),
   artist_name    varchar(100),
   primary key(customer_name,artist_name),
   foreign key(customer_name) references CUSTOMER(name)
   on delete cascade,
   foreign key(artist_name)   references ARTIST(name)
   on delete cascade
  );


  create table if not exists CUSTOMER_PREFERS_GROUP
  (
   customer_name  varchar(100),
   group_name     varchar(100),
   primary key(customer_name,group_name),
   foreign key(customer_name) references CUSTOMER(name)
   on delete cascade,
   foreign key(group_name)    references ART_GROUP(group_name)
   on delete cascade
  );

--save a purchase of a customer
  create table if not exists PURCHASE
(
   purchase_id varchar(20),
   customer_name varchar(100) not null,
   artwork_title varchar(100) unique not null,
   purchase_date timestamp default current_timestamp,
   primary key(purchase_id),
   foreign key(customer_name) references CUSTOMER(name),
   foreign key(artwork_title) references ARTWORK(title)
);

--create auxiliary tables for trigger methods
  create table if not exists  SPONSOR_TRACKER
  (
   sponsor_id    varchar(20),
   customer_name varchar(100) not null,
   message       text         not null,
   created_at    timestamp    default current_timestamp,
   primary key (sponsor_id),
   foreign key(customer_name) references CUSTOMER(name)
   on delete restrict
  );
