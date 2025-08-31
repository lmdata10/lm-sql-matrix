
-- Solve the following SQL problems using the Sales Order dataset:

SELECT * FROM customers; -- 92
SELECT * FROM products; -- 109
SELECT * FROM sales_order; -- 2823


-- 1) Fetch all the small shipped orders FROM August 2003 till the end of year 2003.

SELECT *
FROM sales_order
WHERE status = 'Shipped'
  AND deal_size = 'Small'
  AND order_date BETWEEN '2003-08-01' AND '2003-12-31'
ORDER BY order_date;

-- 2) Find all the orders which do not belong to customers FROM USA and are still in process.

SELECT
	s.order_number
	, s.status
	, c.customer_id
	, c.country
FROM sales_order s
JOIN customers c
	ON c.customer_id = s.customer
WHERE status = 'In Process'
	AND c.country <> 'USA';


-- 3) Find all orders for Planes, Ships and Trains which are neither Shipped nor In Process nor Resolved.

SELECT
	s.order_number
	, s.status
	, p.product_line
FROM sales_order s 
JOIN products p 
	ON s.product = p.product_code
WHERE p.product_line IN ('Planes', 'Ships', 'Trains')
	AND s.status NOT IN ('Shipped', 'In Process', 'Resolved');

-- 4) Find customers whose phone number has either parenthesis "()" or a plus sign "+".

SELECT *
FROM customers
WHERE phone LIKE '%(%'
	OR phone LIKE '%)%'
	OR phone LIKE'%+%';

-- OR WHERE phone IS NOT NULL AND phone LIKE '%[()+]%';
-- using REGEXP WHERE phone IS NOT NULL AND phone REGEXP '[()+]';

-- 5) Find customers whose phone number does not have any space.

SELECT *
FROM customers
WHERE phone NOT LIKE '% %';

-- 6) Fetch all the orders between Feb 2003 and May 2003 where the quantity ordered was an even number.

SELECT *
FROM sales_order
WHERE order_date BETWEEN '2003-02-01' AND '2003-05-31'
	AND quantity_ordered % 2 = 0;

-- 7) Find orders which sold the product for price higher than its original price.

SELECT s.order_number, s.price_each, p.price
FROM sales_order s
JOIN products p 
	ON p.product_code = s.product
WHERE s.price_each > p.price;

-- 8) Find the average sales order price

SELECT
	ROUND(CAST(AVG(price_each) AS DECIMAL),2) AS average_sales_order_price
FROM sales_order;


-- 9) Count total no of orders.

SELECT
	COUNT(DISTINCT order_number) AS total_no_of_orders
FROM sales_order

-- 10) Find the total quantity sold.

SELECT
	SUM(quantity_ordered) AS total_quantity_sold
FROM sales_order

-- 11) Fetch the first order date and the last order date.

SELECT
	MIN(order_date) AS first_order_date
	, MAX(order_date) AS last_order_date
FROM sales_order;

-- 12) Find the average sales order price based on deal size

SELECT
	deal_size,
	ROUND(CAST(AVG(sales) AS DECIMAL),2) AS average_sales_order_price
FROM sales_order
GROUP BY deal_size
ORDER BY average_sales_order_price;


-- 13) Find total no of orders per each day. Sort data based on highest orders.

SELECT
	order_date
	, COUNT(DISTINCT order_number) as total_no_of_orders
FROM sales_order
GROUP BY order_date
ORDER BY total_no_of_orders DESC;

-- For Databricks SQL the query would look like
-- DATE_FORMAT(order_date, 'EEEE') AS day_of_week

-- 14) Display the total sales figure for each quarter. Represent each quarter with their respective period.

SELECT
	qtr_id,
	CASE
		WHEN qtr_id = 1 THEN 'JAN-MAR'
		WHEN qtr_id = 2 THEN 'APR-JUN'
		WHEN qtr_id = 3 THEN 'JUL-SEP'
		ELSE 'OCT-DEC'
	END AS period,
	ROUND(CAST(SUM(sales) AS DECIMAL),2) AS total_sales
FROM sales_order
GROUP BY qtr_id
ORDER BY qtr_id;

-- 15) Identify how many cars, Motorcycles, trains and ships are available in the inventory.
-- Treat all type of cars as just "Cars".

SELECT product_line,
	COUNT(*) AS total_vehicles
FROM products
WHERE product_line IN ('Motorcycles', 'Trains', 'Ships')
GROUP BY product_line
UNION ALL
SELECT
	'Cars' AS product_line,
	COUNT(*) AS total_vehicles
FROM products
WHERE LOWER(product_line) LIKE '%cars%'

-- Solution 2

SELECT
	CASE
		WHEN LOWER(product_line) LIKE '%car%' THEN 'Cars'
		ELSE  product_line
	END AS vehicle_type
	, COUNT(*) AS total_vehicles
FROM products
WHERE product_line IN ('Motorcycles', 'Trains', 'Ships')
	OR LOWER(product_line) LIKE '%cars%'
GROUP BY
	/* CASE
		WHEN LOWER(product_line) LIKE '%car%' THEN 'Cars'
		ELSE  product_line
	END
	-- In Postgres, you can group by the alias 'vehicle_type' directly, but in Databricks, you must use a subquery 
	or CTE to group by the alias, or use the full CASE statement in the GROUP BY clause. --
	*/
	vehicle_type;


-- 16) Identify the vehicles in the inventory which are short in number.
-- Shortage of vehicle is considered when there are less than 10 vehicles.

SELECT product_line,
	COUNT(*) AS total_vehicles
FROM products
GROUP BY product_line
HAVING COUNT(*) < 10;

-- 17) Find the countries which have purchased more than 500 motorcycles.

SELECT 
	c.country
	, COUNT(p.product_line) AS no_of_orders
	, SUM(s.quantity_ordered) AS total_qty_ordered
FROM customers c 
JOIN sales_order s
	ON c.customer_id = s.customer
JOIN products p 
	ON s.product = p.product_code
WHERE LOWER(p.product_line) = 'motorcycles'
GROUP BY c.country
HAVING SUM(s.quantity_ordered) > 500
ORDER BY 3 DESC;

-- 18) Find the orders where the sales amount is incorrect.
WITH cte AS (
SELECT 
	order_number
	, quantity_ordered
	, price_each
	, ROUND(CAST (sales AS DECIMAL),2) AS recorded_sales
	, ROUND(CAST((quantity_ordered * price_each) AS DECIMAL),2) AS real_sales_amount
FROM sales_order
)
SELECT order_number
FROM CTE
WHERE real_sales_amount <> recorded_sales

-- 19) Fetch the total sales done for each day.

SELECT order_date, ROUND(CAST(SUM(sales) AS DECIMAL),2) AS total_sales
FROM sales_order
GROUP BY order_date
ORDER BY order_date

-- 20) Fetch the top 3 months which have been doing the lowest sales.
SELECT 
	EXTRACT( MONTH FROM order_date) AS order_month
	,TO_CHAR(order_date, 'Month') AS month_name
	, SUM(sales) AS total_sales
FROM sales_order
GROUP BY 
	EXTRACT( MONTH FROM order_date)
	,TO_CHAR(order_date, 'Month')
ORDER BY total_sales
LIMIT 3;


-- 21) Find total no of orders per each day of the week (monday to sunday). Sort data based on highest orders.

SELECT
	COUNT(DISTINCT order_number) as total_no_of_orders,
	TO_CHAR(order_date, 'Day') AS day_of_week
FROM sales_order
GROUP BY TO_CHAR(order_date, 'Day')
ORDER BY total_no_of_orders DESC;

-- 22) Find out the vehicles which was sold the most and which was sold the least. Output should be a single record with 2 columns. One column for most sold vehicle and other for least sold vehicle.

-- CROSS JOIN / Sub Query solution
SELECT 
	*
FROM
	(SELECT
		p.product_line || ' - ' || SUM(s.quantity_ordered) AS most_sold_vehicle
	FROM sales_order s
	JOIN products p
		ON p.product_code = s.product
	GROUP BY p.product_line
	ORDER BY SUM(s.quantity_ordered) DESC
	LIMIT 1
	) sub1,
	(SELECT
		p.product_line || ' - ' || SUM(s.quantity_ordered) AS least_sold_vehicle
	FROM sales_order s
	JOIN products p
		ON p.product_code = s.product
	GROUP BY p.product_line
	ORDER BY SUM(s.quantity_ordered)
	LIMIT 1
	) sub2


