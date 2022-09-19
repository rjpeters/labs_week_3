USE sakila;


--    1. Drop column picture from staff.

DELETE picture FROM staff;


--    2. A new person is hired to help Jon. Her name is TAMMY SANDERS, and she is a customer. Update the database accordingly.

-- Get Tammy's info
SELECT * FROM customer WHERE first_name = "TAMMY" AND last_name = "SANDERS";

-- Check what info goes into the 'staff' table.
SELECT * FROM staff;
-- Since she will "help Jon" I'm going to assume she'll work at store 2 (where Jon works)

INSERT INTO staff 
VALUES (3, "Tammy", "Sanders", 79, NULL, "TAMMY.SANDERS@sakilacustomer.org", 2, 1, "Tammy", NULL, NOW() );

SELECT i.inventory_id FROM inventory i
WHERE i.film_id = (
SELECT film_id FROM film WHERE title = 'Academy Dinosaur')
AND i.store_id = 1;

-- Add rental for movie "Academy Dinosaur" by Charlotte Hunter from Mike Hillyer at Store 1. 
-- Mike Hillyer is employee 1, Academy Dinosaur has film ID 1. Just for fun, I'll get Charlotte Hunter's customer ID in a subquery: 

-- It turns out there are 4 copies of Academy Dinosaur at store 1. I'll just go with inventory ID 1.
SELECT i.inventory_id FROM inventory i
WHERE i.film_id = (
SELECT film_id FROM film WHERE title = 'Academy Dinosaur')
AND i.store_id = 1;

-- Now, I'll check again which values I need to add
SELECT * FROM rental;

-- Then inserting values
INSERT INTO rental
VALUES (16050, NOW(),  1, (SELECT customer_id FROM customer WHERE first_name = "Charlotte" AND last_name = "Hunter"), NULL, 1, NOW());

-- Then check if it worked
SELECT * FROM rental;
