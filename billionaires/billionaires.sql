----------------------------------
-- CLEAN-UP
----------------------------------

-- DROP EXISTING DB
DROP DATABASE IF EXISTS billionaires WITH (FORCE);

----------------------------------
-- INITIALIZATION OF NEW DB
----------------------------------

-- CREATE DB
CREATE DATABASE billionaires;

-- SWITCH TO NEW DB
\c billionaires;

----------------------------------
-- INSTALLATION OF EXTENSIONS
----------------------------------

-- GET UUID EXTENSION
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

----------------------------------
-- GENERATE TABLES
----------------------------------

-- CREATE TABLE 'INITIAL-DATA'
CREATE TABLE IF NOT EXISTS initial_data (
    name VARCHAR(100),
    country VARCHAR(50),
    industry VARCHAR(100),
    net_worth DECIMAL(10, 2),
    company VARCHAR(100)
);

-- CREATE TABLE 'BILLIONAIRES'
CREATE TABLE IF NOT EXISTS billionaires (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100),
    country VARCHAR(50),
    industry VARCHAR(100),
    net_worth DECIMAL(10, 2),
    company VARCHAR(100)
);

-- CREATE TABLE 'PERSONS'
CREATE TABLE IF NOT EXISTS persons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    firstname VARCHAR(30),
    lastname VARCHAR(30),
    net_worth DECIMAL(10, 2)
);

-- CREATE TABLE 'COMPANY'
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(30)
);

-- CREATE TABLE 'COUNTRY'
CREATE TABLE countries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50)
);

----------------------------------
-- IMPORT DATA FROM CSV
----------------------------------

-- IMPORT DATA TO DB 'INITIAL-DATA'
\COPY initial_data FROM '/Users/jeromehaas/Development/database-scripts/billionaires/billionaires.csv' DELIMITER ',' CSV HEADER;

----------------------------------
-- DEFINE DB 'BILLIONAIRES'
----------------------------------

-- INSERT DATA IN NEW DB
INSERT INTO billionaires (name, country, industry, net_worth, company)
    SELECT name, country, industry, net_worth, company
    FROM initial_data;

-- CREATE TEMPORARY COLUMNS FOR FIRSTNAME AND LASTNAME IN BILLIONAIRES
ALTER TABLE billionaires
    ADD COLUMN firstname VARCHAR(30),
    ADD COLUMN lastname VARCHAR(30);

-- ADD TEMPORARY FIRSTNAME AND LASTNAME TO BILLIONAIRES
UPDATE billionaires
    SET firstname = split_part(billionaires.name, ' ', 1),
        lastname = split_part(billionaires.name, ' ', 2)
    WHERE firstname IS NULL AND lastname IS NULL;

-- LINK BILLIONAIRES AND COMPANIES
ALTER TABLE billionaires
    ADD COLUMN fk_company_id UUID REFERENCES companies(id);

-- ADD COLUMN FOR FOREIGN KEY IN BILLIONAIRES
ALTER TABLE billionaires
    ADD COLUMN fk_person_id UUID REFERENCES persons(id);

-- ADD COLUMN FOR FOREIGN KEY IN BILLIONAIRES
ALTER TABLE billionaires
    ADD COLUMN fk_country_id UUID REFERENCES countries(id);

----------------------------------
-- DEFINE DB 'PERSONS'
----------------------------------

-- MOVE THE NAMES FROM BILLIONAIRES TO PERSONS
INSERT INTO persons (firstname, lastname)
    SELECT DISTINCT firstname, lastname
    FROM billionaires;

-- FILL DATA FOR COMPANIES
INSERT INTO companies (name)
    SELECT DISTINCT company FROM billionaires;

----------------------------------
-- DEFINE DB 'COUNTRIES'
----------------------------------

-- FILL COUNTRIES
INSERT INTO countries (name)
    SELECT DISTINCT country
    FROM billionaires;

----------------------------------
-- UPDATE TABLES
----------------------------------

-- UPDATE LINK
UPDATE billionaires
    SET fk_company_id = companies.id
    FROM companies
    WHERE billionaires.company = companies.name;

-- LINK THE ID FROM PERSONS TO BILLIONAIRES
UPDATE billionaires
    SET fk_person_id = persons.id
    FROM persons
    WHERE billionaires.firstname = persons.firstname AND billionaires.lastname = persons.lastname;

-- LINK THE ID FROM COUTNRIES TO BILLIONAIRES
UPDATE billionaires
    SET fk_country_id = countries.id
    FROM countries
    WHERE billionaires.country = countries.name;

-- INSERT NET-WORTH
UPDATE persons
    SET net_worth = billionaires.net_worth
    FROM billionaires
    WHERE persons.id = billionaires.fk_person_id;

----------------------------------
-- DELETE UNUSED COLUMNS AND TABLES
----------------------------------

-- DROP OLD DB
DROP TABLE initial_data;

-- DROP COMPANY
ALTER TABLE billionaires
    DROP COLUMN company;

-- DROP UNUSED NAME TABLES
ALTER TABLE billionaires
    DROP COLUMN firstname,
    DROP COLUMN lastname,
    DROP COLUMN name,
    DROP COLUMN country;


----------------------------------
-- PRINT DATA
----------------------------------

-- PRINT BILLIONAIRES AND COMPANIES
-- SELECT * FROM billionaires;
-- SELECT * FROM companies;
