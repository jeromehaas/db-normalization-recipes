------------------------------------
-- CLEAN UP
------------------------------------

-- DROP CURRENT DB
DROP DATABASE flight_logs;

------------------------------------
-- INIT NEW DB
------------------------------------

-- CREATE NEW DB
CREATE DATABASE flight_logs;

-- CHANGE DB
\c flight_logs;

------------------------------------
-- GENERATE TABLES
------------------------------------

-- CREATE TABLE "FLIGHT_LOGS"
CREATE TABLE flight_logs
(
    flight_number     VARCHAR(20),
    departure_airport VARCHAR(10),
    arrival_airport   VARCHAR(10),
    departure_date    DATE,
    arrival_date      DATE,
    departure_time    TIME,
    arrival_time      TIME,
    airline           VARCHAR(20),
    flight_duration   FLOAT,
    passenger_count   INT,
    ticket_price      DECIMAL(10, 2),
    cabin_class       VARCHAR(20),
    flight_status     VARCHAR(20),
    aircraft_type     VARCHAR(50),
    pilot_name        VARCHAR(100),
    co_pilot_name     VARCHAR(100)
);

-- CREATE TABLES FOR *AIRPORTS*
CREATE TABLE airports (
    airport_id   SERIAL PRIMARY KEY,
    airport_name VARCHAR(5)
);

------------------------------------
-- IMPORT DATA
------------------------------------

-- IMPORT CSV TO DATABASE
\COPY flight_logs FROM 'C:\Users\hello\Development\sql-scripts\flight-logs\flight-logs.csv' DELIMITER ',' CSV HEADER;

------------------------------------
-- MODIFY TABLE 'FLIGHT_LOGS'
------------------------------------

-- INSERT DATA INTO *AIRPORTS*
INSERT INTO airports (airport_name) (
    SELECT DISTINCT departure_airport
    FROM flight_logs
    UNION
    SELECT DISTINCT arrival_airport
    FROM flight_logs
);

-- CREATE ATTRIBUTES FOR *DEPARTMENT-AIRPORT-ID* AND *ARRIVAL-AIRPORT-ID*
ALTER TABLE flight_logs
    ADD COLUMN fk_departure_airport_id INT,
    ADD CONSTRAINT fk_departure_airport FOREIGN KEY (fk_departure_airport_id) REFERENCES airports (airport_id);


-- ADD CORRECT IDS FOR DEPARTURE AIRPORT AND ARRIVAL AIRPORT
UPDATE flight_logs
SET fk_departure_airport_id = (
    SELECT airports.airport_id
    FROM airports
    WHERE airports.airport_name = flight_logs.departure_airport
);
