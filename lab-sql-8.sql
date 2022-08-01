
USE sakila;

-- Write a query to display for each store its store ID, city, and country.

SELECT s.store_id as store_id, c.city as city, co.country as country FROM store as s
JOIN address as a
ON s.address_id = a.address_id
JOIN city as c
ON a.city_id = c.city_id
JOIN country as co
ON c.country_id = co.country_id;

-- Write a query to display how much business, in dollars, each store brought in.

SELECT s.store_id, CONCAT(sum(p.amount), "$") as business_from_each_store
FROM payment as p
JOIN staff as s
ON p.staff_id = s.staff_id
GROUP BY store_id;

-- Which film categories are longest?

SELECT c.name as category, avg(length) as duration FROM category as c
JOIN film_category as fc
ON c.category_id = fc.category_id
JOIN film as f
ON fc.film_id = f.film_id
GROUP BY c.name
ORDER BY avg(length) desc;

-- Display the most frequently rented movies in descending order.

SELECT f.title, count(rental_id) FROM rental as r
JOIN inventory as i
ON r.inventory_id = i.inventory_id
JOIN film as f
ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY count(rental_id) desc;

-- List the top five genres in gross revenue in descending order.

SELECT c.name as genre, sum(p.amount) as gross_revenue FROM category as c
JOIN film_category as f
ON c.category_id = f.category_id
JOIN inventory as i
ON f.film_id = i.film_id
JOIN rental as r
ON i.inventory_id = r.inventory_id
JOIN payment as p
ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY sum(p.amount) desc
LIMIT 5;

-- Is "Academy Dinosaur" available for rent from Store 1?

SELECT * FROM film as f
JOIN inventory as i
ON f.film_id = i.film_id
JOIN store as s
ON i.store_id = s.store_id
WHERE f.title = "Academy Dinosaur" and s.store_id = 1;

-- Yes it is!

-- Get all pairs of actors that worked together.

SELECT concat(ac1.first_name, " ", ac1.last_name), fa1.film_id, concat(ac2.first_name, " ", ac2.last_name) FROM film_actor as fa1
JOIN film_actor as fa2
on fa1.film_id = fa2.film_id 
AND fa1.actor_id < fa2.actor_id
JOIN actor as ac1 
ON fa1.actor_id = ac1.actor_id
JOIN actor as ac2 
ON fa2.actor_id = ac2.actor_id;

-- Get all pairs of customers that have rented the same film more than 3 times.

SELECT c.customer_id, i.film_id, count(rental_id)  as number_of_times_same_film_was_rented
FROM customer as c
JOIN rental as r
ON c.customer_id = r.customer_id 
JOIN inventory as i
ON r.inventory_id = i.inventory_id
GROUP BY c.customer_id, i.film_id
HAVING count(rental_id) > 2
ORDER BY customer_id;

SELECT * FROM customer;

-- No two customers rented the same film more than 3 times!

-- For each film, list actor that has acted in more films.

WITH ordered_values AS(
SELECT film_id, actor_id, number_of_acted_movies, rank() OVER
(PARTITION BY film_id ORDER BY number_of_acted_movies DESC) as rn
FROM (
SELECT film_id, act.actor_id, max(number_of_acted_movies) AS number_of_acted_movies
	FROM (
		SELECT
			actor_id, count(film_id) as number_of_acted_movies
		FROM film_actor
		GROUP BY actor_id
	) AS act
	LEFT JOIN film_actor as fa
	ON act.actor_id = fa.actor_id
	JOIN actor as a
	ON act.actor_id = a.actor_id
	GROUP BY film_id, act.actor_id
	ORDER BY film_id
) as t1
)
SELECT 
    film_id, number_of_acted_movies, concat(first_name, " ", last_name) as actor_name
FROM 
    ordered_values
JOIN actor as a
ON ordered_values.actor_id = a.actor_id
WHERE rn =1;


