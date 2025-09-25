-- ============================================================
-- WINDOW FUNCTIONS IN ACTION
-- ============================================================


-- We will be using the sql_problems database.

CREATE DATABASE sql_problems;

-- ========================
-- RANK()
-- ========================

-- INSERT SCRIPT

-- Drop and recreate EU energy table
DROP TABLE IF EXISTS fb_eu_energy;
CREATE TABLE fb_eu_energy (
    date        DATE,
    consumption INT
);

-- Drop and recreate Asia energy table
DROP TABLE IF EXISTS fb_asia_energy;
CREATE TABLE fb_asia_energy (
    date        DATE,
    consumption INT
);

-- Drop and recreate NA energy table
DROP TABLE IF EXISTS fb_na_energy;
CREATE TABLE fb_na_energy (
    date        DATE,
    consumption INT
);

-- Insert data into EU table
INSERT INTO fb_eu_energy VALUES ('2020-01-01', 400);
INSERT INTO fb_eu_energy VALUES ('2020-01-02', 350);
INSERT INTO fb_eu_energy VALUES ('2020-01-03', 500);
INSERT INTO fb_eu_energy VALUES ('2020-01-04', 500);
INSERT INTO fb_eu_energy VALUES ('2020-01-07', 600);

-- Insert data into Asia table
INSERT INTO fb_asia_energy VALUES ('2020-01-01', 400);
INSERT INTO fb_asia_energy VALUES ('2020-01-02', 400);
INSERT INTO fb_asia_energy VALUES ('2020-01-04', 675);
INSERT INTO fb_asia_energy VALUES ('2020-01-05', 1200);
INSERT INTO fb_asia_energy VALUES ('2020-01-06', 750);
INSERT INTO fb_asia_energy VALUES ('2020-01-07', 400);

-- Insert data into NA table
INSERT INTO fb_na_energy VALUES ('2020-01-01', 250);
INSERT INTO fb_na_energy VALUES ('2020-01-02', 375);
INSERT INTO fb_na_energy VALUES ('2020-01-03', 600);
INSERT INTO fb_na_energy VALUES ('2020-01-06', 500);
INSERT INTO fb_na_energy VALUES ('2020-01-07', 250);

-- Check the data
SELECT * FROM fb_eu_energy;
SELECT * FROM fb_asia_energy;
SELECT * FROM fb_na_energy;

/* 
===== PROBLEM =====

Find the date with the highest total energy consumption from the Meta/Facebook data centers.

Output:
    - The date
    - The total energy consumption across all data centers

Note: If there are multiple days with the same highest energy consumption, display all such dates.
*/

-- ===== SOLUTION =====

/*
Step 1: Combine all three data center tables.  
    - We use UNION ALL (not JOIN) to avoid losing rows.  
Step 3: Apply RANK() over total consumption in descending order.  
    - This lets us capture ties for highest consumption.  
Step 4: Filter only rows with rnk = 1 (the maximum).  
*/

WITH all_data_centers AS (
    SELECT * FROM fb_eu_energy
    UNION ALL
    SELECT * FROM fb_asia_energy
    UNION ALL
    SELECT * FROM fb_na_energy
)
,date_wise_consumption AS (
    SELECT 
        date,
        SUM(consumption) AS total_energy_consumption,
        RANK() OVER (ORDER BY SUM(consumption) DESC) AS rnk
    FROM all_data_centers
    GROUP BY date
)
SELECT 
    date,
    total_energy_consumption
FROM date_wise_consumption
WHERE rnk = 1;


-- ========================
-- LEAD() & LAG()
-- ========================

-- From the students table, write a SQL query to interchange the adjacent student names.
-- Note: If there are no adjacent students, the student name should stay the same.


-- Setup: Create Students Table

DROP TABLE IF EXISTS students;

CREATE TABLE students (
    id           INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL
);

-- Insert sample data
INSERT INTO students (id, student_name) VALUES
    (1, 'James'),
    (2, 'Michael'),
    (3, 'George'),
    (4, 'Stewart'),
    (5, 'Robin');

-- Check the data
SELECT * FROM students;


-- ===== SOLUTION =====

/*
Logic:
1. The CASE statement checks if the ID is even or odd.
2. For odd IDs, LEAD looks ahead to the next row (the adjacent even ID) to get its name.
3. For even IDs, LAG looks back at the previous row (the adjacent odd ID) to get its name.
4. The OVER (ORDER BY id) clause ensures the functions operate on rows in the correct order.
5. The third argument in LEAD (student_name) acts as a default value, handling the last odd-numbered row correctly.
*/

SELECT
    id
    ,student_name
    ,CASE
        WHEN id%2 = 0 THEN LAG(student_name,1) OVER (ORDER BY id)
        ELSE LEAD(student_name,1,student_name) OVER (ORDER BY id)
    END AS swapped_student_name
FROM students;



-- =============================================
-- FIRST_VALUE(), LAST_VALUE() & Frame Clause
-- =============================================

-- Setup: Create product Table

CREATE TABLE product (
    product_category VARCHAR(255),
    brand VARCHAR(255),
    product_name VARCHAR(255),
    price INT
);

INSERT INTO product (product_category, brand, product_name, price) VALUES
    ('Phone', 'Apple', 'iPhone 16 Pro Max', 1300),
    ('Phone', 'Apple', 'iPhone 16 Pro', 1100),
    ('Phone', 'Apple', 'iPhone 16', 1000),
    ('Phone', 'Samsung', 'Galaxy Z Fold 6', 1800),
    ('Phone', 'Samsung', 'Galaxy Z Flip 6', 1000),
    ('Phone', 'Samsung', 'Galaxy S24 Ultra', 1200),
    ('Phone', 'Samsung', 'Galaxy S24', 1000),
    ('Phone', 'Nothing', 'Nothing Phone 2a', 300),
    ('Phone', 'Google', 'Pixel 9 Pro', 900),
    ('Phone', 'Google', 'Pixel 9', 600),
    ('Laptop', 'Apple', 'MacBook Pro 16', 3000),
    ('Laptop', 'Apple', 'MacBook Air', 1200),
    ('Laptop', 'Microsoft', 'Surface Laptop 7', 2100),
    ('Laptop', 'Dell', 'XPS 13', 2000),
    ('Laptop', 'Dell', 'XPS 15', 2300),
    ('Laptop', 'Dell', 'XPS 17', 2500),
    ('Earphone', 'Apple', 'AirPods Pro', 280),
    ('Earphone', 'Samsung', 'Galaxy Buds 3 Pro', 220),
    ('Earphone', 'Samsung', 'Galaxy Buds 3', 170),
    ('Earphone', 'Sony', 'WF-1000XM4', 250),
    ('Headphone', 'Sony', 'WH-1000XM4', 400),
    ('Headphone', 'Apple', 'AirPods Max', 550),
    ('Headphone', 'Microsoft', 'Surface Headphones 2', 250),
    ('Smartwatch', 'Apple', 'Apple Watch Series 10', 1000),
    ('Smartwatch', 'Apple', 'Apple Watch SE', 400),
    ('Smartwatch', 'Samsung', 'Galaxy Watch 5 Pro', 600),
    ('Smartwatch', 'Google', 'Pixel Watch 3', 220);

-- Q) Write query to display the most expensive and least expensive product under each category (corresponding to each record)

SELECT 
    *
    , FIRST_VALUE(product_name) 
        OVER (PARTITION BY product_category ORDER BY price DESC) AS most_exp_prod
    , LAST_VALUE(product_name) 
        OVER (PARTITION BY product_category ORDER BY price DESC) AS least_exp_prod -- No Frame Clause
FROM product;

-- Why are we getting different results in each row for the least_exp_prod????
/*
FIRST_VALUE(product_name) → looks at the partition (product_category), orders by price DESC, and picks the first row. 
That’s your most expensive product in the category.

LAST_VALUE(product_name) without a frame → defaults to RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.
This means it doesn’t show the true least expensive product — it only shows the product of the current row as you move down the partition.

This is why people often get tripped up with LAST_VALUE.
*/

-- Let's check LAST_VALUE with frame clause

SELECT 
    *
    , LAST_VALUE(product_name) 
        OVER (PARTITION BY product_category ORDER BY price DESC
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS least_exp_running
    , LAST_VALUE(product_name) 
        OVER (PARTITION BY product_category ORDER BY price DESC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS true_least_exp_prod
FROM product;

-- =============================================
-- Frame Clause Explanation
-- =============================================

/* RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW OR DEFAULT LAST_VALUE processing without Frame.
Frame covers rows from the start of the partition up to the current row.
LAST_VALUE here just mirrors the current row’s product.
*/

/* RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
Frame covers all rows in the partition, no matter the current row.
LAST_VALUE now gives the actual least expensive product in the entire category.
*/

-- =============================================
-- NTH_VALUE()
-- =============================================

-- Nth Value (SQL Server doesn't support it, but can be used in Snowflake, databricks, postgres)
SELECT 
    *
    ,NTH_VALUE(product_name, 2) 
        OVER (PARTITION BY product_category ORDER BY price DESC
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS second_exp_prod
FROM product;

/*
- NTH_VALUE(expr, n) → gives you the nth row’s value from the current window frame.
- Here, expr = product_name and n = 2.
- That means: “Find the second product in the current frame.”
- On the first row: frame only has 1 row → no “second row” exists → NULL.
- On the second row: frame has 2 rows → the 2nd product is the current row → result = that product.
- On the third row (and every row after): frame still has at least 2 rows, so NTH_VALUE keeps showing the product at position 2 from the top.
*/

-- =============================================
-- AGGREGATE Functions as Window Functions
-- =============================================
SELECT 
    *
    , COUNT(*) OVER (PARTITION BY product_category) AS total_no_of_prod
    , SUM(price) OVER (PARTITION BY product_category) AS total_price_within_window
    , MAX(price) OVER (PARTITION BY product_category) AS max_price_within_window
    , MIN(price) OVER (PARTITION BY product_category) AS min_price_within_window
FROM product;

-- =============================================
-- NTILE() Creates buckets
-- =============================================

-- Q. Write a query to roughly segregate all the expensive phones, mid range phones and the cheaper phones.
/* 
NTILE(n) splits your sorted rows into n buckets of roughly the same size.
First, it sorts all the rows by your chosen column (ORDER BY).
Then it divides them into buckets.
If the rows don’t divide evenly, the first few buckets get 1 extra row.

Example: 10 rows, 4 buckets
Total rows: 10
Buckets: 4
Base size: 10 ÷ 4 = 2 rows per bucket, remainder 2

Distribute remainder:
First 2 buckets get 1 extra row each.
*/

SELECT 
    *
    , CASE 
        WHEN bucket = 1 THEN 'Expensive Phones'
        WHEN bucket = 2 THEN 'Mid-Range Phones'
        ELSE 'Cheaper Phones' 
    END AS category
FROM (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY price DESC) AS bucket
    FROM product 
    WHERE product_category = 'Phone'
) sub;

