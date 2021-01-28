/*
Lab | SQL Rolling calculations
In this lab, you will be using the Sakila database of movie rentals.

Instructions
1. Get number of monthly active customers.
2. Active users in the previous month.
3. Percentage change in the number of active customers.
4. Retained customers every month.
*/
-- 1. Get number of monthly active customers.
SELECT COUNT(c.customer_id) n_customers, MONTH(r.rental_date) month, YEAR(r.rental_date) year
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id
WHERE active = 1
GROUP BY 3,2;

-- 2. Active users in the previous month.
SELECT *
FROM (

SELECT c.customer_id, MONTH(r.rental_date) month, YEAR(r.rental_date) year, c.active active,
	   LAG(c.active,1) OVER (PARTITION BY c.customer_id ORDER BY YEAR(r.rental_date), MONTH(r.rental_date)) AS active_last_month
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id ) AS x
WHERE active_last_month = 1;

-- 3. Percentage change in the number of active customers.
SELECT SUM(change_) / COUNT(*) * 100
FROM (
SELECT c.customer_id, MONTH(r.rental_date) month, YEAR(r.rental_date) year, c.active active,
	   LAG(c.active,1) OVER (PARTITION BY c.customer_id ORDER BY YEAR(r.rental_date), MONTH(r.rental_date)) AS active_last_month,
       CASE WHEN c.active = LAG(c.active,1) OVER (PARTITION BY c.customer_id ORDER BY YEAR(r.rental_date), MONTH(r.rental_date)) THEN 0
			ELSE 1 END AS change_
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id ) AS X;

-- 4. Retained customers every month.
SELECT COUNT(customer_id) n_customers, month, year
FROM (
SELECT * FROM (
SELECT c.customer_id, MONTH(r.rental_date) month, YEAR(r.rental_date) year, c.active active,
	   LAG(c.active,1) OVER (PARTITION BY c.customer_id ORDER BY YEAR(r.rental_date), MONTH(r.rental_date)) AS active_last_month,
       CASE WHEN c.active = 1 AND LAG(c.active,1) OVER (PARTITION BY c.customer_id ORDER BY YEAR(r.rental_date) = 1, MONTH(r.rental_date)) THEN 1
			ELSE 0 END AS retain_
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id) AS x
WHERE retain_ = 1) AS x
group by 3,2
--