-- Database: ComicDom

-- DROP DATABASE IF EXISTS "ComicDom";

/*CREATE DATABASE  "ComicDom"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;*/

--question1

--create artists table 
	create table if not exists ARTIST
	(
      name        varchar(100),
	  birth_place varchar(100) not null,
	  age         integer check(age>0 ) not null,
	  art_style   varchar(100) not null,
	  primary key (name)	  
	);

--creation of artwork table 

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


/*

--question2

/*α. Βρείτε τα ονόματα των πελατών που έχουν ξοδέψει, συνολικά στo φεστιβάλ,
πάνω από €50.000, και οι οποίοι έχουν δηλώσει ότι τους αρέσουν όλες οι
ομάδες τέχνης που περιέχουν τη λέξη 'Manga' στο όνομά τους. Δεν είναι
σίγουρο ότι η ομάδα τέχνης γράφεται ως 'Manga' ή 'manga' ή λίγο διαφορετικά.*/

select c.name
from customer c
where c.money_spent > 50000
and not exists
(
   select *
   from art_group g
   where g.group_name ilike '%manga%'
   and not exists
   (
      select *
      from customer_prefers_group cpg
      where cpg.customer_name = c.name
      and cpg.group_name = g.group_name
   )
);

/*β. Εμφανίστε το όνομα του καλλιτέχνη, τον τύπο τέχνης (π.χ. comic, anime) και τη
μέση τιμή των έργων του για τον συγκεκριμένο τύπο. Στο αποτέλεσμα πρέπει να
συμπεριληφθούν μόνο οι καλλιτέχνες των οποίων η μέση τιμή σε αυτόν τον τύπο
τέχνης είναι μεγαλύτερη από τη μέση τιμή όλων των έργων τέχνης του ίδιου
τύπου στην γκαλερί.*/
select a.artist_name,a.art_type,avg(a.price) as average_price
from artwork a
group by a.artist_name, a.art_type
having avg(a.price) >
(
   select avg(a2.price)
   from artwork a2
   where a2.art_type = a.art_type
);

/*γ . Βρείτε τα ονόματα των ομάδων τέχνης τα οποία δεν περιέχουν κανένα έργο
τέχνης αυτή τη στιγμή, αλλά περιλαμβάνουν τουλάχιστον έναν καλλιτέχνη που
αρέσει σε περισσότερους από 10 πελάτες (με βάση τις προτιμήσεις των πελατών).*/
select g.group_name
from art_group g
left join artwork_group ag
   on g.group_name = ag.group_name
where ag.artwork_title is null
and exists
(
   select *
   from artwork_group ag2
   join artwork aw
      on ag2.artwork_title = aw.title
   where ag2.group_name = g.group_name
   and aw.artist_name in
   (
      select artist_name
      from customer_prefers_artist
      group by artist_name
      having count(customer_name) > 10
   )
);

/* δ. Εμφανίστε τους καλλιτέχνες που έχουν δημιουργήσει έργα σε τουλάχιστον 3
διαφορετικούς τύπους τέχνης (π.χ. comic και anime και graphic novel) και
ταυτόχρονα, τουλάχιστον ένα έργο τους ανήκει σε ομάδα η οποία περιέχει τη
λέξη 'manga'.*/
select a.artist_name , count(a.art_type)
from artwork a
group by a.artist_name
having count( distinct a.art_type) >= 3
and exists
(
   select *
   from artwork aw
   join artwork_group ar
      on aw.title = ar.artwork_title
   where aw.artist_name = a.artist_name
   and ar.group_name ilike '%manga%'
);

/* ε. Βρείτε τους πελάτες οι οποίοι έχουν ξοδέψει τα περισσότερα χρήματα στην έκθεση
(κορυφαίο 5% των πελατών με βάση το ποσό κατανάλωσης), αλλά δεν έχουν
δηλώσει καμία προτίμηση για κανέναν καλλιτέχνη (ο πίνακας προτιμήσεων
καλλιτεχνών για αυτούς είναι άδειος), εμφανίζοντας και τον αριθμό των ομάδων
τέχνης που τους αρέσουν.*/

with top_customers as
(
   select ceil(count(*) * 0.05) as top_n
   from customer
)
select c.name, c.money_spent, count(cpg.group_name) as liked_groups
from customer c
left join customer_prefers_group cpg
   on c.name = cpg.customer_name
where not exists
(
   select *
   from customer_prefers_artist cpa
   where cpa.customer_name = c.name
)
group by c.name, c.money_spent
order by c.money_spent desc
limit
(
   select top_n
   from top_customers
);






--question 3

--part1
--trigger for purchase
create or replace function update_customer_spending()
returns trigger
as $$
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
$$ language plpgsql;

create trigger trigger_update_customer_spending
after insert on purchase
for each row
execute function update_customer_spending();


--part2
do $$
declare

   rec_count integer := 0;
   rec record;
   artist_rec record;
   artwork_rec record;

begin
--find the customers that have spent more than 20000
   for rec in
      select *
      from customer
      where money_spent > 20000
   loop
      rec_count := 0;
--find the artists that the customers admires
      for artist_rec in
         select artist_name
         from customer_prefers_artist
         where customer_name = rec.name
      loop
--if the artwork of the artist exists 
         for artwork_rec in
            select *
            from artwork ar
            where ar.artist_name = artist_rec.artist_name
            and not exists
            (
               select *
               from purchase p
               where p.artwork_title = ar.title
            )
         loop
            rec_count := rec_count + 1;
            raise notice
            'Αγαπητέ %, ο καλλιτέχνης % που αγαπάτε έχει ένα διαθέσιμο έργο με τίτλο % στην τιμή των % euro.',
            rec.name,
            artist_rec.artist_name,
            artwork_rec.title,
            artwork_rec.price;
            if rec_count > 3 then
               exit;
            end if;
   end loop;
   end loop;
   end loop;

end;
$$;
*/
