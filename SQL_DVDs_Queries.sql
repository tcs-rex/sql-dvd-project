/* ----------- QS_2-3 -------------
(Udacity Question Set #2 - Question #3)
Finally, for each of these top 10 paying customers, I would like to find out the difference across their monthly payments during 2007. Please go ahead and write a query to compare the payment amounts in each successive month. Repeat this for each of these 10 paying customers. Also, it will be tremendously helpful if you can identify the customer name who paid the most difference in terms of payments.
*/

	WITH top_10 AS
		(SELECT
			 DATE_TRUNC('year', payment_date),
			 first_name || ' ' || last_name AS first_last,
			 SUM(amount)
		FROM customer cus
		JOIN payment pay
		ON cus.customer_id = pay.customer_id AND NOT amount = 0
		GROUP BY DATE_TRUNC('year', payment_date), first_last
		ORDER BY 3 DESC
		LIMIT 10),

		mthly_data AS
		(SELECT
			 DATE_TRUNC('month', payment_date) AS mth,
			 first_name || ' ' || last_name AS first_last,
			 COUNT(payment_id) AS mthly_pay_count,
			 SUM(amount) AS mthly_pay_tally
		FROM customer cus
		JOIN payment pay
		ON cus.customer_id = pay.customer_id AND NOT amount = 0
		GROUP BY DATE_TRUNC('month', payment_date), first_last)

SELECT
CASE WHEN DATE_PART('month',mth) = 2 THEN 'Feb'
	 WHEN DATE_PART('month',mth) = 3 THEN 'Mar'
	 WHEN DATE_PART('month',mth) = 4 THEN 'Apr'
	 WHEN DATE_PART('month',mth) = 5 THEN 'May' END AS Month_2007,
first_last,
mthly_pay_tally - COALESCE(LAG(mthly_pay_tally) OVER (PARTITION BY first_last ORDER BY mth), 0) AS Top_10_Customer_2007_Monthly_Pay_Differences
FROM
	(SELECT mth, top_10.first_last, mthly_pay_count, mthly_pay_tally
	FROM top_10
	JOIN mthly_data
	ON top_10.first_last = mthly_data.first_last) top_10_mthly_data;

/* ----------- QS_2-2 -------------
(Udacity Question Set #2 - Question #2)
We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and what was the amount of the monthly payments. Can you write a query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers?
*/

WITH top_10 AS
	(SELECT
		 DATE_TRUNC('year', payment_date),
		 first_name || ' ' || last_name AS first_last,
		 SUM(amount)
	FROM customer cus
	JOIN payment pay
	ON cus.customer_id = pay.customer_id AND NOT amount = 0
	GROUP BY DATE_TRUNC('year', payment_date), first_last
	ORDER BY 3 DESC
	LIMIT 10),

	mthly_data AS
	(SELECT
		 DATE_TRUNC('month', payment_date) AS Mth,
		 first_name || ' ' || last_name AS first_last,
		 COUNT(payment_id) AS mthly_pay_count,
		 SUM(amount) AS mthly_pay_tally
	FROM customer cus
	JOIN payment pay
	ON cus.customer_id = pay.customer_id AND NOT amount = 0
	GROUP BY DATE_TRUNC('month', payment_date), first_last)

SELECT mth, top_10.first_last, mthly_pay_count, mthly_pay_tally
FROM top_10
JOIN mthly_data
ON top_10.first_last = mthly_data.first_last
ORDER BY 2,1;


/* ----------- QS_2-1 -------------
(Udacity Question Set #2 - Question #1)
We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for. Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month.*/

SELECT
store.store_id Store_Num,
DATE_PART('month',rental_date) AS Rental_Mth,
DATE_PART('year',rental_date) AS Rental_Yr,
COUNT(rental_date) Num_Rentals
FROM store
JOIN staff
ON store.store_id = staff.store_id
JOIN rental
ON rental.staff_id = staff.staff_id
GROUP BY 1,2,3
ORDER BY 4 DESC;

/*modified query version for slide visualization below (used combined year and month, and reformatted)
(SELECT
store.store_id Store_Num,
to_char(DATE_TRUNC('month',rental_date), 'YYYY-MM') AS Year_Month,
COUNT(rental_date) Num_Rentals
FROM store
JOIN staff
ON store.store_id = staff.store_id
JOIN rental
ON rental.staff_id = staff.staff_id
GROUP BY 1,2
ORDER BY 2);
*/

/* ----------- QS_1-3 -------------
(Udacity Question Set #1 - Question #3)
Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category for each corresponding rental duration category. The resulting table should have three columns:
*/

SELECT category, quartile_rental_duration, COUNT(quartile_rental_duration)
FROM
	(SELECT
		name category,
		rental_duration,
		NTILE(4) OVER (ORDER BY  rental_duration) AS quartile_rental_duration
	FROM
		(SELECT title, category_id, f.film_id f_id, f.rental_duration
		FROM film f
		JOIN film_category fc
		ON f.film_id = fc.film_id) sub1
	JOIN category c
	ON c.category_id = sub1.category_id AND (name LIKE 'Ani%' OR name LIKE 'Chi%' OR name LIKE 'Cla%' OR name LIKE 'Com%' OR name LIKE 'Fam%' OR name LIKE 'Mus%')) sub2
GROUP BY 1,2
ORDER BY 1,2;
