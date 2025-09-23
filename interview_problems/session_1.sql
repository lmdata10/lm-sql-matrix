-- We will be using the sql_problems database.

CREATE DATABASE sql_problems;

-- ============================================================
-- Interview Problem 1
-- ============================================================

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


-- ============================================================
-- Interview Problem 2
-- ============================================================

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