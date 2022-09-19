USE sakila;



--    1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id) FROM inventory
WHERE film_id = (SELECT film_id FROM film WHERE title = 'Hunchback Impossible');


--    2. List all films whose length is longer than the average of all the films.
SELECT title, length 
	FROM film
WHERE length >
	(SELECT AVG(length) FROM film);


--    3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT CONCAT(first_name, ' ', last_name) FROM actor a
WHERE a.actor_id IN 
	(SELECT fa.actor_id FROM film_actor fa
	WHERE fa.film_id = 
		(SELECT f.film_id FROM film f
        WHERE f.title = 'Alone Trip')
        );
	;
    
    
--    4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title FROM film f
JOIN film_category fc USING(film_id)
WHERE fc.category_id = (SELECT fc.category_id FROM category cat WHERE cat.name = 'Family');


--    5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

-- SUBQUERY EDITION
SELECT CONCAT(first_name, ' ', last_name) AS name, email FROM customer
WHERE address_id IN 
	(SELECT address_id FROM address
    WHERE city_id IN 
		(SELECT city_id FROM city
        WHERE country_id = 
			(SELECT country_id FROM country
            WHERE country = 'Canada')
		)
    );

-- JOIN EDITION
SELECT CONCAT(first_name, ' ', last_name) AS name, email FROM customer c
JOIN address a USING(address_id)
JOIN city ci USING(city_id)
JOIN country co USING(country_id)
WHERE co.country = 'Canada';


--    7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

-- This is a tricky one. First thing is to get the most profitable customer. 
SELECT c.customer_id, SUM(p.amount) AS amount FROM customer c
	JOIN payment p USING(customer_id)
	GROUP BY c.customer_id
	ORDER BY SUM(p.amount) DESC
	LIMIT 1;

-- The obvious thing to do would be to put this as a subquery, but that doesn't work: 
-- If you use '=' it complains that it only wants one column, 
-- If you use 'IN', it gives error 'This version of MySQL doesn't yet support 'LIMIT & IN/ALL/ANY/SOME subquery'

SELECT f.title FROM film f
JOIN inventory i USING(film_id)
JOIN rental r USING(inventory_id)
WHERE r.customer_id IN 
(SELECT c.customer_id, SUM(p.amount) AS amount FROM customer c
	JOIN payment p USING(customer_id)
	GROUP BY c.customer_id
	ORDER BY SUM(p.amount) DESC
	LIMIT 1);
    
    
--    8. Customers who spent more than the average payments.

SELECT  AVG(TOTAL)
FROM   (SELECT   PLAYERNO, SUM(AMOUNT) AS TOTAL
        FROM     PENALTIES
        GROUP BY PLAYERNO) AS TOTALS
WHERE   PLAYERNO IN
       (SELECT   PLAYERNO
        FROM     PLAYERS
        WHERE    TOWN = 'Stratford' OR TOWN = 'Inglewood');

SELECT DISTINCT customer_id FROM 
(SELECT customer_id, SUM(amount) AS revenue FROM payment GROUP BY SUM(amount)) AS newtable
WHERE SUM(amount) > (SELECT AVG(amount) FROM payment);
-- MAKE THIS THE SUM OF AMOUNT PER CUSTOMER
