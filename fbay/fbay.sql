------------------------------------
-- CLEAN UP
------------------------------------

-- DROP EXISTING DB
DROP DATABASE IF EXISTS fbay WITH (FORCE);

------------------------------------
-- INIT NEW DB
------------------------------------

-- CREATE DB
CREATE DATABASE fbay;

-- SWITCH DIRECTORY
\c fbay;

------------------------------------
-- GENERATE TABLES
------------------------------------

-- CREATE TABLE 'INITIAL-DATA'
CREATE TABLE initial_data (
    product VARCHAR(255),
    description VARCHAR(255),
    quantity INT,
    price DECIMAL(10, 2),
    date DATE,
    customer VARCHAR(255),
    category VARCHAR(100),
    condition VARCHAR(50),
    brand VARCHAR(100),
    rating DECIMAL(2, 1)
);

-- CREATE TABLE 'PRODUCTS'
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    description VARCHAR(255),
    quantity INT,
    price DECIMAL(10, 2),
    date DATE,
    rating DECIMAL(2, 1),
    temp_customer VARCHAR(255),
    temp_category VARCHAR(100),
    temp_condition VARCHAR(50),
    temp_brand VARCHAR(100),
    fk_customer_id INT,
    fk_category_id INT,
    fk_condition_id INT,
    fk_brand_id INT
);

-- CREATE TABLE 'CUSTOMER'
CREATE TABlE customers (
    id SERIAL PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50)
);

-- CREATE TABLE 'CATEGORY'
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    category VARCHAR(50)
);

-- CREATE TABLE 'CONDITION'
CREATE TABLE conditions (
    id SERIAL PRIMARY KEY,
    condition VARCHAR(50)
);

-- CREATE TABLE FOR 'BRAND'
CREATE TABLE brands (
    id SERIAL PRIMARY KEY,
    brand VARCHAR(100)
);

------------------------------------
-- IMPORT DATA
------------------------------------

-- DEFINE MONTH FORMAT
SET datestyle = 'ISO, DMY';

-- IMPORT CSV
\COPY initial_data FROM 'C:\Users\hello\Development\sql-scripts\fbay\fbay.csv' DELIMITER ',' CSV HEADER;

------------------------------------
-- MODIFY TABLE 'PRODUCTS'
------------------------------------

-- ADD FOREIGN KEY 'FK-CATEGORY-ID'
ALTER TABLE products
    ADD CONSTRAINT fk_customer
    FOREIGN KEY (fk_customer_id) REFERENCES customers(id);

-- ADD FOREIGN KEY 'FK-CATEGORY-ID'
ALTER TABLE products
    ADD CONSTRAINT fk_category
    FOREIGN KEY (fk_category_id) REFERENCES categories(id);

-- ADD FOREIGN KEY 'FK-CONDITION'
ALTER TABLE products
    ADD CONSTRAINT fk_condition
    FOREIGN KEY (fk_condition_id) REFERENCES conditions(id);

-- ADD FOREIGN KEY 'FK-REFERENCES'
ALTER TABLE products
    ADD CONSTRAINT fk_brand
    FOREIGN KEY (fk_brand_id) REFERENCES brands(id);

-- INSERT DATA
INSERT INTO products (description, quantity, price, date, rating, temp_customer, temp_category, temp_condition, temp_brand)
    SELECT description, quantity, price, date, rating, customer, category, condition, brand
    FROM initial_data;

------------------------------------
-- MODIFY TABLE 'CUSTOMERS'
------------------------------------

-- INSERT FIRSTNAME AND LASTNAME
INSERT INTO customers (firstname, lastname)
    SELECT DISTINCT
        split_part(customer, ' ', 1) AS firstname,
        split_part(customer, ' ', 2) AS lastname
    FROM initial_data;

------------------------------------
-- MODIFY TABLE 'CATEGORIES'
------------------------------------

-- INSERT CATEGORIES
INSERT INTO categories (category)
    SELECT DISTINCT category
    FROM initial_data;

------------------------------------
-- MODIFY TABLE 'CONDITIONS'
------------------------------------

-- INSERT CONDITIONS
INSERT INTO conditions (condition)
    SELECT DISTINCT condition
    FROM initial_data;

------------------------------------
-- MODIFY TABLE 'BRANDS'
------------------------------------

-- INSERT BRANDS
INSERT INTO brands (brand)
    SELECT DISTINCT brand
    FROM initial_data;

------------------------------------
-- INSERT FOREIGN-KEYS
------------------------------------

-- ADD FOREIGN-KEY 'FK-CUSTOMER-ID'
UPDATE products
    SET fk_customer_id = customers.id
    FROM customers
    WHERE products.temp_customer = customers.firstname || ' ' || customers.lastname;

-- ADD FOREIGN KEY 'FK-BRAND-ID'
UPDATE products
    SET fk_brand_id = brands.id
    FROM brands
    WHERE products.temp_brand = brands.brand;

-- ADD FOREIGN KEY 'FK-CATEGORY-ID'
UPDATE products
    SET fk_category_id = categories.id
    FROM categories
    WHERE products.temp_category = categories.category;

-- ADD FOREIGN KEY 'FK-CONDITION-ID'
UPDATE products
    SET fk_condition_id = conditions.id
    FROM conditions
    WHERE products.temp_condition = conditions.condition;

------------------------------------
-- REMOVE UNUSED TABLES AND ATTRIBUTES
------------------------------------

-- DROP TABLE 'INITIAL-DATA'
DROP TABLE initial_data;

-- DELETE TEMPORARY ATTRIBUTES FROM TABLE 'PRODUCTS'
ALTER TABLE products
    DROP COLUMN temp_customer,
    DROP COLUMN temp_category,
    DROP COLUMN temp_condition,
    DROP COLUMN temp_brand;

