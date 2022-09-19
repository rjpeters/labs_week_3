USE sakila;



--    1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id) FROM inventory
WHERE film_id = (SELECT film_id FROM film WHERE title = 'Hunchback Impossible');

-- **********************************************************************


--    2. List all films whose length is longer than the average of all the films.
SELECT title, length 
	FROM film
WHERE length >
	(SELECT AVG(length) FROM film);

-- **********************************************************************


--    3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT CONCAT(first_name, ' ', last_name) FROM actor a
WHERE a.actor_id IN 
	(SELECT fa.actor_id FROM film_actor fa
	WHERE fa.film_id = 
		(SELECT f.film_id FROM film f
        WHERE f.title = 'Alone Trip')
        );

    
-- **********************************************************************
    
    
--    4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title FROM film f
JOIN film_category fc USING(film_id)
WHERE fc.category_id = (SELECT fc.category_id FROM category cat WHERE cat.name = 'Family');

-- **********************************************************************

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

-- **********************************************************************


--    6. Which are films starred by the most prolific actor? 
-- Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

-- Step 1:
SELECT actor_id, COUNT(film_id) as films FROM film_actor
GROUP BY actor_id
ORDER BY films DESC
LIMIT 1;

-- Step 2 (I'm making this look easy but I did this one last - you can see the record of my struggles below):

SELECT title FROM film
JOIN film_actor fa USING(film_id) 
WHERE fa.actor_id = (SELECT actor_id FROM
(SELECT actor_id, COUNT(film_id) as films FROM film_actor
GROUP BY actor_id
ORDER BY films DESC
LIMIT 1) temp );

-- **********************************************************************


--    7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

-- This is a tricky one - I'll walk you throught the whole process. First thing is to get the most profitable customer. 
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

-- I can make it work by creating a temporary table:    
CREATE TEMPORARY TABLE customer_profit
(SELECT c.customer_id, SUM(p.amount) AS amount FROM customer c
	JOIN payment p USING(customer_id)
	GROUP BY c.customer_id
	ORDER BY SUM(p.amount) DESC
	LIMIT 1);
    
SELECT f.title, r.customer_id FROM film f -- adding the customer_id column just to check that this is all the same person.
JOIN inventory i USING(film_id)
JOIN rental r USING(inventory_id)
WHERE r.customer_id = (SELECT customer_id FROM customer_profit);

-- And now that I've done everything, I can tie it together using the trick I learned in exercise 8 (see below)
SELECT f.title, r.customer_id FROM film f 
JOIN inventory i USING(film_id)
JOIN rental r USING(inventory_id)
WHERE r.customer_id = (SELECT customer_id FROM (SELECT c.customer_id, SUM(p.amount) AS amount FROM customer c
	JOIN payment p USING(customer_id)
	GROUP BY c.customer_id
	ORDER BY SUM(p.amount) DESC
	LIMIT 1) blabla );


-- **********************************************************************

--    8. Customers who spent more than the average payments.

-- First I'll create a temporary table again (after fiddling around with this for 30 minutes I think that's the best option)
CREATE TEMPORARY TABLE total_spent AS
(SELECT CONCAT(c.first_name, ' ', c.last_name) as Name, SUM(p.amount) as Spent FROM customer c
JOIN payment p USING(customer_id)
GROUP BY Name);

-- The obvious thing won't work, because apparently temporary tables are a little less flexible than normal ones:
SELECT * FROM total_spent
WHERE Spent > (SELECT AVG(Spent) FROM total_spent);

-- So instead, I'll use the same logic I used to create the temporary table, and use the temporary table only at the end: 
SELECT CONCAT(c.first_name, ' ', c.last_name) as Name, SUM(p.amount) as spent FROM customer c
JOIN payment p USING(customer_id)
GROUP BY Name
HAVING spent > (SELECT AVG(Spent) FROM total_spent);

-- Finally, an experiment to see if I can do the same thing without temporary tables: 

SELECT CONCAT(c.first_name, ' ', c.last_name) as Name, SUM(p.amount) as spent FROM customer c
JOIN payment p USING(customer_id)
GROUP BY Name
HAVING spent > (SELECT AVG(Spent) FROM (SELECT CONCAT(c.first_name, ' ', c.last_name) as Name, SUM(p.amount) as Spent FROM customer c
JOIN payment p USING(customer_id)
GROUP BY Name) xyz );

-- And to my astonishment, that worked! The only thing was that I had to add the alias for the 'derived table' (I chose 'xyz')


-- 