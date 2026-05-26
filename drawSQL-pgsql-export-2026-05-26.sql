CREATE TABLE "ARTIST"(
    "name" VARCHAR(255) NOT NULL,
    "birthplace" VARCHAR(255) NOT NULL,
    "age" SMALLINT NOT NULL,
    "art_style" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "ARTIST" ADD PRIMARY KEY("name");
CREATE TABLE "ART_PIECE"(
    "title" VARCHAR(255) NOT NULL,
    "year_of_creation" INTEGER NOT NULL,
    "art_type" VARCHAR(255) NOT NULL,
    "price" FLOAT(53) NOT NULL,
    "artist_name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "ART_PIECE" ADD PRIMARY KEY("title");
CREATE TABLE "ARTWORK_GROUP"(
    "artwork_title" VARCHAR(255) NOT NULL,
    "group_name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "ARTWORK_GROUP" ADD PRIMARY KEY("artwork_title");
ALTER TABLE
    "ARTWORK_GROUP" ADD PRIMARY KEY("group_name");
CREATE TABLE "CUSTOMER"(
    "name" VARCHAR(255) NOT NULL,
    "address" VARCHAR(255) NOT NULL,
    "money_spent" FLOAT(53) NOT NULL
);
ALTER TABLE
    "CUSTOMER" ADD PRIMARY KEY("name");
CREATE TABLE "CUSTOMER_PREFERS_ARTIST"(
    "customer_name" VARCHAR(255) NOT NULL,
    "artist_name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "CUSTOMER_PREFERS_ARTIST" ADD PRIMARY KEY("customer_name");
ALTER TABLE
    "CUSTOMER_PREFERS_ARTIST" ADD PRIMARY KEY("artist_name");
CREATE TABLE "CUSTOMER_PREFERS_GROUP"(
    "customer_name" VARCHAR(255) NOT NULL,
    "group_name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "CUSTOMER_PREFERS_GROUP" ADD PRIMARY KEY("customer_name");
ALTER TABLE
    "CUSTOMER_PREFERS_GROUP" ADD PRIMARY KEY("group_name");
CREATE TABLE "ART_GROUP"(
    "group_name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "ART_GROUP" ADD PRIMARY KEY("group_name");
ALTER TABLE
    "CUSTOMER_PREFERS_GROUP" ADD CONSTRAINT "customer_prefers_group_group_name_foreign" FOREIGN KEY("group_name") REFERENCES "ARTWORK_GROUP"("group_name");
ALTER TABLE
    "CUSTOMER_PREFERS_ARTIST" ADD CONSTRAINT "customer_prefers_artist_artist_name_foreign" FOREIGN KEY("artist_name") REFERENCES "ARTIST"("name");
ALTER TABLE
    "CUSTOMER_PREFERS_GROUP" ADD CONSTRAINT "customer_prefers_group_customer_name_foreign" FOREIGN KEY("customer_name") REFERENCES "CUSTOMER"("name");
ALTER TABLE
    "CUSTOMER_PREFERS_ARTIST" ADD CONSTRAINT "customer_prefers_artist_customer_name_foreign" FOREIGN KEY("customer_name") REFERENCES "CUSTOMER"("name");
ALTER TABLE
    "ART_PIECE" ADD CONSTRAINT "art_piece_artist_name_foreign" FOREIGN KEY("artist_name") REFERENCES "ARTIST"("name");
ALTER TABLE
    "ART_GROUP" ADD CONSTRAINT "art_group_group_name_foreign" FOREIGN KEY("group_name") REFERENCES "ARTWORK_GROUP"("group_name");
ALTER TABLE
    "ARTWORK_GROUP" ADD CONSTRAINT "artwork_group_artwork_title_foreign" FOREIGN KEY("artwork_title") REFERENCES "ART_PIECE"("title");