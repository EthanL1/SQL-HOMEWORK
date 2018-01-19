#1.a  Display the first and last names of all actors from the table `actor`. 
Select first_name, last_name from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name)) as 'Actor Name' from actor;

#2a You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = 'Joe';

#2bFind all actors whose last name contain the letters `GEN`:
SELECT * FROM actor 
WHERE last_name LIKE '%GEN%';

#2c Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor 
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

#2d Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country FROM Country 
WHERE country IN('Afghanistan', 'Bangladesh', 'China');

# 3A Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD middle_name VARCHAR(100)  AFTER first_name;

# 3B You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor
modify middle_name BLOB;
 
# 3c. Now delete the `middle_name` column.
Alter table actor
DROP column middle_name;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) from actor
Group BY 1
ORDER BY 2 DESC; 

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(*) from actor
Group BY 1
HAVING count(last_name) > 1
order by 2 DESC; 

#* 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

Update actor SET first_name ='HARPO', last_name ='WILLIAMS' 
WHERE first_name ='GROUCHO' AND last_name ='WILLIAMS';

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)

update actor
set first_name = case
    when first_name = 'Harpo' THEN 'GROUCHO'
    when first_name = 'Groucho' THEN 'MUCHO GROUCHO'
    else first_name
END;

# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?



CREATE TABLE address1(
	address_id smallint(5)  PRIMARY KEY auto_increment,
    address varchar(50),
    address2 varchar(50) NOT NULL,
    district varchar(20),
    city_id smallint(5),
    postal_code VARCHAR(10) NOT NULL, 
    phone VARCHAR(20),
    location geometry,
    last_updated timestamp default CURRENT_TIMESTAMP on UPDATE current_timestamp);
    


#  6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT A.first_name, A.last_name, L.* from staff A
INNER JOIN address L
on A.address_id = L.address_id;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 

SELECT concat(S.first_name, ' ', S.last_name) as 'Name', sum(P.amount) as 'Total Sales Per Employee' from staff S
join Payment P 
on P.staff_id = S.staff_id
Where monthname(P.payment_date) = 'August' and year(P.payment_date) = 2005
Group by 1; 

# List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT 
    F.title, COUNT(A.actor_id) AS '# Of Actors'
FROM
    film F
        INNER JOIN
    film_actor A ON F.film_id = A.film_id
GROUP BY F.title
ORDER BY 2 DESC;


#6d. How many copies of the film `Hunchback Impossible` exist in the inventory system? CHECK

SELECT Count(film_id) from inventory
where film_id = (select distinct film_id from film where title = 'Hunchback Impossible');

#6e  Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

Select C.first_name, C.last_name, sum(P.amount) from customer C
Inner join payment P
on C.customer_id = P.customer_id
Group by 1,2
ORDER by 2,1 DESC;

#7A  The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 



SELECT F.title FROM FILM  F   WHERE F.language_id in (select L.language_id from language L where L.name = 'english')
and F.title like 'K%' or 'Q%';






#7b Use subqueries to display all actors who appear in the film `Alone Trip`

SELECT 
    CONCAT(A.first_name, ' ', A.last_name) as 'Full NAME'
FROM
    actor A
WHERE
    A.actor_id IN (SELECT 
            FA.actor_id
        FROM
            film_actor FA
        WHERE
            FA.film_id = (SELECT 
                    F.film_id
                FROM
                    film F
                WHERE
                    F.title = 'Alone Trip'));

select * from film_actor;


##7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.


SELECT 
    C.first_name, C.last_name, C.email, CO.Country
FROM
    customer C
        JOIN
    address A ON A.address_id = C.address_id
        JOIN
    city CI ON CI.city_id = A.city_id
        JOIN
    country CO ON CO.country_id = CI.country_id
WHERE
    CO.country = 'Canada';

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

Select F.title, C.name 
from 
	Film F 
		join
        film_category FC on fc.film_id = f.film_id 
        join
	category C on c.category_id = fc.category_id 
WHERE C.name like '%Family';

#7e. Display the most frequently rented movies in descending order.  

SELECT F.title, count(F.title) as 'Number of Times Rented' from Film F
join 
inventory I on F.film_id = I.film_id  
join 
rental R on R.inventory_id =I.inventory_id
GROUP BY F.title
order by 2 desc;


# 7f. Write a query to display how much business, in dollars, each store brought in.

SELECt S.store_ID as 'Store', sum(P.amount) as 'Sales Amount' from store s
join inventory I 
on I.store_id = S.store_id
join rental R
on R.inventory_id = I.inventory_id
join Payment P
on P.rental_id = R.rental_id
group by 1;
# 7g. Write a query to display for each store its store ID, city, and country.
SELECT S.store_id, C.city, CO.country from store S
join
address A on S.address_id = A.address_id 
join
city C on A.city_id = C.city_id
Join
Country CO on C.country_id = CO.country_id; 
# 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT 
    CAT.name, SUM(PAY.amount) AS 'SALES PER CATEGORY'
FROM
    category CAT
        JOIN
    film_category FC ON FC.category_id = CAT.category_id
        JOIN
    inventory I ON I.film_id = FC.film_id
        JOIN
    rental R ON R.inventory_id = I.inventory_id
        JOIN
    payment PAY ON PAY.rental_id = R.rental_id
GROUP BY CAT.name
ORDER BY 2 DESC
LIMIT 5;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
Create View TOP_5_genre as

SELECT  CAT.name, SUM(PAY.amount) AS 'SALES PER CATEGORY'
FROM
    category CAT
        JOIN
    film_category FC ON FC.category_id = CAT.category_id
        JOIN
    inventory I ON I.film_id = FC.film_id
        JOIN
    rental R ON R.inventory_id = I.inventory_id
        JOIN
    payment PAY ON PAY.rental_id = R.rental_id
GROUP BY CAT.name
ORDER BY 2 DESC
LIMIT 5;


# 8b. How would you display the view that you created in 8a?
SELECt * from top_5_genre;


#8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_5_genre;
