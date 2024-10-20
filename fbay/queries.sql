------------------------------------
-- GENERAL QUERIES
------------------------------------

-- SHOW ALL PRODUCTS THAT ARE NEW
SELECT
   products.id,
   products.description
FROM products
INNER JOIN conditions ON products.fk_condition_id = conditions.id
WHERE conditions.condition = 'Neu';

-- SHOW ALL PRODUCTS INCLUDING THE CUSTOMER
SELECT
    products.id,
    products.description,
    products.rating,
    customers.firstname,
    customers.lastname
FROM products
INNER JOIN customers ON products.fk_customer_id = customers.id;
