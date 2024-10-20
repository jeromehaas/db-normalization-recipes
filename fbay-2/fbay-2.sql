----------------------------------
-- SETUP DB
----------------------------------

-- DROP EXISTING DB 'FBAY-2'
DROP DATABASE IF EXISTS fbay_2 WITH (FORCE);

-- CREATE NEW DB 'FBAY-2'
CREATE DATABASE fbay_2;

-- CHANGE DIRECTORY
\c fbay_2;

----------------------------------
-- SETUP TABLES
----------------------------------

-- CREATE TABLE 'INITIAL-DATA'
CREATE TABLE initial_data (
    product VARCHAR(255),
    description VARCHAR(255),
    num_bet INT,
    high_bet INT,
    auction_end DATE,
    highest_bidder VARCHAR(255),
    category VARCHAR(255),
    state VARCHAR(255),
    make VARCHAR(255),
    bidder_rating DECIMAL(3, 1)
);

-- CREATE TABLE 'AUCTIONS'
CREATE TABLE auctions (
    auction_id SERIAL PRIMARY KEY,
    num_bet INT,
    highest_bet INT,
    auction_end DATE
);

-- CREATE TABLE 'PRODUCTS'
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255),
    description VARCHAR(255),
    category VARCHAR(255),
    state VARCHAR(255),
    make VARCHAR(255),
    bidder_rating DECIMAL(3, 1)
);

-- CREATE TABLE 'BIDDERS'
CREATE TABLE bidders (
    bidder_id SERIAL PRIMARY KEY,
    firstname VARCHAR(100),
    lastname VARCHAR(100)
);

-- CREATE TABLE 'BIDS'
CREATE TABLE bids (
    bid_id SERIAL PRIMARY KEY,
    bid_amount INT
);

----------------------------------
-- IMPORT DATA
----------------------------------

-- DEFINE MONTH FORMAT
SET datestyle = 'ISO, DMY';

-- IMPORT CSV
\COPY initial_data FROM 'C:\Users\hello\Development\sql-scripts\fbay-2\fbay-2.csv' DELIMITER ',' CSV HEADER;

----------------------------------
-- DEFINE REFERENCES
----------------------------------

-- ADD REFERENCE FOR 'PRODUCT' IN 'AUCTIONS'
ALTER TABLE auctions
    ADD COLUMN fk_product_id INT,
    ADD CONSTRAINT fk_product FOREIGN KEY (fk_product_id) REFERENCES products(product_id);

-- ADD REFERENCE FOR 'HIGHES-BIDER' IN 'AUCTIONS'
ALTER TABLE auctions
    ADD COLUMN fk_highest_bidder_id INT,
    ADD CONSTRAINT fk_highest_bidder FOREIGN KEY (fk_highest_bidder_id) REFERENCES bidders(bidder_id);

-- ADD REFERENCE FOR 'AUCTION' IN 'BIDS'
ALTER TABLE bids
    ADD COLUMN fk_auction_id INT,
    ADD CONSTRAINT fk_auction FOREIGN KEY (fk_auction_id) REFERENCES auctions(auction_id);

-- ADD REFERENCE FOR 'BIDDER' IN 'BIDS'
ALTER TABLE bids
    ADD COLUMN fk_bidder_id INT,
    ADD CONSTRAINT fk_bidder FOREIGN KEY (fk_bidder_id) REFERENCES bidders(bidder_id);

----------------------------------
-- INSERT DATA IN TABLES
----------------------------------

-- INSERT DATA INTO TABLE 'BIDDERS'
INSERT INTO bidders (firstname, lastname)
    SELECT DISTINCT
        split_part(highest_bidder, ' ', 1) AS firstname,
        split_part(highest_bidder, ' ', 2) AS lastname
    FROM initial_data;

-- INSERT DATA INTO TABLE 'PRODUCTS'
INSERT INTO products (product_name, description, category, state, make, bidder_rating)
    SELECT DISTINCT
        product,
        description,
        category,
        state,
        make,
        bidder_rating
    FROM initial_data;

-- INSERT DATA INTO TABLE 'AUCTIONS'
INSERT INTO auctions (fk_product_id, num_bet, highest_bet, auction_end, fk_highest_bidder_id)
SELECT products.product_id, initial_data.num_bet, initial_data.high_bet, initial_data.auction_end::date, bidders.bidder_id
    FROM initial_data
    JOIN products ON initial_data.product = products.product_name
    JOIN bidders ON initial_data.highest_bidder = bidders.firstname || ' ' || bidders.lastname;

-- INSERT DATA INTO BIDS
INSERT INTO bids (bid_amount, fk_auction_id, fk_bidder_id)
SELECT auctions.highest_bet, auctions.auction_id, bidders.bidder_id
    FROM auctions
    JOIN bidders ON auctions.fk_highest_bidder_id = bidders.bidder_id;

----------------------------------
-- CLEAN-UP
----------------------------------

-- DROP TABLE 'INITIAL-DATA'
DROP TABLE initial_data;



