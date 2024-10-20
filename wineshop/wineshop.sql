---------------------
-- CLEANUP
---------------------

-- DROP EXISTING DB
DROP DATABASE IF EXISTS wineshop WITH (FORCE);

---------------------
-- INIT NEW DB
---------------------

-- CREATE NEW  DB
CREATE
DATABASE wineshop;

-- SWITCH DIRECTORY
\c wineshop

---------------------
-- CREATE NEW TABLES
---------------------

-- CREATE TABLE 'INITIAL-DATA'
CREATE TABLE initial_data
(
    brand           VARCHAR(255),
    type            VARCHAR(255),
    price           DECIMAL(10, 2),
    number          INT,
    grape_variety   VARCHAR(255),
    vintage         INT,
    region          VARCHAR(255),
    alcohol_content DECIMAL(5, 2),
    bottle_size     VARCHAR(50),
    rating          DECIMAL(3, 2),
    description     TEXT,
    image_url       VARCHAR(2083),
    country         VARCHAR(255)
);

-- CREATE TABLE 'WINES'
CREATE TABLE wines
(
    id                  SERIAL PRIMARY KEY,
    number              INT,
    vintage             INT,
    alcohol_content    DECIMAl(5, 2),
    bottle_size         VARCHAR(50),
    rating              DECIMAL(3, 2),
    description         TEXT,
    image_url           VARCHAR(2083),
    fk_type_id          INT,
    fk_grape_variety_id INT,
    fk_region_id        INT,
    fk_country_id       INT,
    temp_type           VARCHAR(255),
    temp_grape_variety  VARCHAR(255),
    temp_region         VARCHAR(255),
    temp_country        VARCHAR(255)
);

-- CREATE TABLE 'TYPES'
CREATE TABLE types
(
    id   SERIAL PRIMARY KEY,
    type VARCHAR(255)
);

-- CREATE TABLE 'GRAPE-VARIETIES'
CREATE TABLE grape_varieties
(
    id            SERIAL PRIMARY KEY,
    grape_variety VARCHAR(255)
);

-- CREATE TABLE 'GRAPE-VARIETIES'
CREATE TABLE regions
(
    id     SERIAL PRIMARY KEY,
    region VARCHAR(255)
);

-- CREATE TABLE 'COUNTRIES'
CREATE TABLE countries
(
    id      SERIAL PRIMARY KEY,
    country VARCHAR(255)
);

---------------------
-- IMPORT DATA
---------------------

-- IMPORT CSV DATA
\COPY initial_data FROM 'C:\Users\hello\Development\sql-scripts\wineshop\wineshop.csv' DELIMITER ',' CSV HEADER;

---------------------
-- MODIFY TABLE 'WINES'
---------------------

-- ADD FOREIGN KEY 'TYPE'
ALTER TABLE wines
    ADD CONSTRAINT fk_type
        FOREIGN KEY (fk_type_id) REFERENCES types (id);

-- ADD FOREIGN KEY 'GRAPE-VARIETY'
ALTER TABLE wines
    ADD CONSTRAINT fk_grape_variety
        FOREIGN KEY (fk_grape_variety_id) REFERENCES grape_varieties (id);

-- ADD FOREIGN KEY 'REGION'
ALTER TABLE wines
    ADD CONSTRAINT fk_region
        FOREIGN KEY (fk_region_id) REFERENCES regions (id);

-- ADD FOREIGN KEY 'COUNTRY'
ALTER TABLE wines
    ADD CONSTRAINT fk_country
        FOREIGN KEY (fk_country_id) REFERENCES countries (id);

-- INSERT DATA
INSERT INTO wines (number, vintage, alcohol_content, bottle_size, rating, description, image_url, temp_type, temp_region, temp_grape_variety, temp_country)
    SELECT number, vintage, alcohol_content, bottle_size, rating, description, image_url, type, region, grape_variety, country
    FROM initial_data;

---------------------
-- MODIFY TABLE 'TYPES'
---------------------

-- INSERT TYPES
INSERT INTO types (type)
    SELECT DISTINCT type
    FROM initial_data;

---------------------
-- MODIFY TABLE 'GRAPE-VARIETIES'
---------------------

-- INSERT GRAPE-VARIETIES
INSERT INTO grape_varieties (grape_variety)
    SELECT DISTINCT grape_variety
    FROM initial_data;

---------------------
-- MODIFY TABLE 'REGIONS'
---------------------

-- INSERT REGIONS
INSERT INTO regions (region)
    SELECT DISTINCT region
    FROM initial_data;

---------------------
-- MODIFY TABLE 'COUNTRIES'
---------------------

-- INSERT COUNTRIES
INSERT INTO countries (country)
    SELECT DISTINCT country
    FROM initial_data;


---------------------
-- CONNECT FOREIGN KEYS
---------------------

-- CONNECT 'TYPES'
UPDATE wines
    SET fk_type_id = types.id
    FROM types
    WHERE wines.temp_type = types.type;

-- CONNECT 'GRAPE-VARIETIES'
UPDATE wines
    SET fk_grape_variety_id = grape_varieties.id
    FROM grape_varieties
    WHERE wines.temp_grape_variety = grape_varieties.grape_variety;

-- CONNECT 'REGIONS'
UPDATE wines
    SET fk_region_id = regions.id
    FROM regions
    WHERE wines.temp_region = regions.region;

-- CONNECT 'COUNTRIES'
UPDATE wines
    SET fk_country_id = countries.id
    FROM countries
    WHERE wines.temp_country = countries.country;

------------------------------------
-- REMOVE UNUSED TABLES AND ATTRIBUTES
------------------------------------

-- DROP TABLE 'INITIAL-DATA'
DROP TABLE initial_data;

-- DELETE TEMPORARY ATTRIBUTES FROM TABLE 'PRODUCTS'
ALTER TABLE wines
    DROP COLUMN temp_type,
    DROP COLUMN temp_grape_variety,
    DROP COLUMN temp_region,
    DROP COLUMN temp_country;

