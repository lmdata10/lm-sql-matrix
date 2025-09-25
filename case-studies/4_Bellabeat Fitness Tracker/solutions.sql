
SELECT * FROM daily_activity; -- 940
SELECT * FROM sleep_day; -- 410
SELECT * FROM weight_log; -- 60

/* 
-- ==================================================================================
Problem: Identify the day of the week when the customers are most active and least 
active. Active is determined based on the no of steps.
-- ==================================================================================
*/

WITH active_days AS(
SELECT
    day_of_week
    , SUM(total_steps)
    , FIRST_VALUE(day_of_week) OVER (ORDER BY SUM(total_steps) DESC) AS most_active
    , FIRST_VALUE(day_of_week) OVER (ORDER BY SUM(total_steps)) AS least_active
FROM daily_activity
GROUP BY day_of_week
)
SELECT 
    DISTINCT most_active
, least_active
FROM active_days;

/*
-- ==================================================================================
Problem: Identify the customer who has the most effective sleep. Effective sleep is 
determined based on is customer spent most of the time in bed sleeping. 
-- ==================================================================================
*/
WITH effectiveness AS(
SELECT
	customer_id
	, (SUM(total_time_in_bed) - SUM(total_minutes_asleep)) AS wasted_time
	, RANK() OVER(ORDER BY
		(SUM(total_time_in_bed) - SUM(total_minutes_asleep))) AS effctv_rank
FROM sleep_day
GROUP BY customer_id
)
SELECT 
	customer_id
FROM effectiveness
WHERE effctv_rank = 1;

-- Identify customers with no sleep record.

-- Correlated Subquery
SELECT 
	DISTINCT d.customer_id
FROM daily_activity d
WHERE NOT EXISTS (
	SELECT 
		customer_id 
	FROM sleep_day s 
	WHERE s.customer_id = d.customer_id
);

-- NOT IN Method
SELECT DISTINCT CUSTOMER_ID
FROM DAILY_ACTIVITY
WHERE CUSTOMER_ID NOT IN (
    SELECT CUSTOMER_ID
    FROM SLEEP_DAY
);

-- We can also solve it using JOIN and NULL

/*
-- ==================================================================================
Problem: Fetch all customers whose daily activity, sleep and weight logs are all present.
-- ==================================================================================
*/

SELECT CUSTOMER_ID FROM daily_activity
INTERSECT
SELECT CUSTOMER_ID FROM weight_log
INTERSECT
SELECT CUSTOMER_ID FROM sleep_day;

-- OR

SELECT DISTINCT da.customer_id
FROM daily_activity da
JOIN weight_log wl
    ON da.customer_id = wl.customer_id
JOIN sleep_day sd
    ON da.customer_id = sd.customer_id;


/* 
-- ==================================================================================
Problem: For each customer, display the total hours they slept for each day of the week. 
Your output should contains 8 columns, first column is the customer id and the 
next 7 columns are the day of the week (like monday, tuesday etc)
-- ==================================================================================
*/

-- solution using CASE statement
SELECT customer_id,
       SUM(CASE WHEN day_of_week = 'Monday'    THEN total_minutes_asleep ELSE 0 END) AS monday,
       SUM(CASE WHEN day_of_week = 'Tuesday'   THEN total_minutes_asleep ELSE 0 END) AS tuesday,
       SUM(CASE WHEN day_of_week = 'Wednesday' THEN total_minutes_asleep ELSE 0 END) AS wednesday,
       SUM(CASE WHEN day_of_week = 'Thursday'  THEN total_minutes_asleep ELSE 0 END) AS thursday,
       SUM(CASE WHEN day_of_week = 'Friday'    THEN total_minutes_asleep ELSE 0 END) AS friday,
       SUM(CASE WHEN day_of_week = 'Saturday'  THEN total_minutes_asleep ELSE 0 END) AS saturday,
       SUM(CASE WHEN day_of_week = 'Sunday'    THEN total_minutes_asleep ELSE 0 END) AS sunday
FROM sleep_day
GROUP BY customer_id
ORDER BY customer_id;

-- solution using CROSSTAB
CREATE EXTENSION tablefunc;

SELECT customer_id,
       COALESCE(monday, 0)    AS monday,
       COALESCE(tuesday, 0)   AS tuesday,
       COALESCE(wednesday, 0) AS wednesday,
       COALESCE(thursday, 0)  AS thursday,
       COALESCE(friday, 0)    AS friday,
       COALESCE(saturday, 0)  AS saturday,
       COALESCE(sunday, 0)    AS sunday
FROM CROSSTAB(
        'SELECT customer_id, day_of_week, SUM(total_minutes_asleep) AS total_sleep
         FROM sleep_day
         GROUP BY customer_id, day_of_week
         ORDER BY customer_id, day_of_week',
        'SELECT DISTINCT day_of_week FROM sleep_day'
     )
     AS result(
        customer_id bigint,
        monday      bigint,
        tuesday     bigint,
        wednesday   bigint,
        thursday    bigint,
        friday      bigint,
        saturday    bigint,
        sunday      bigint
     );

-- Solution for SQL Server (T-SQL)
SELECT customer_id,
       COALESCE([Monday], 0)    AS monday,
       COALESCE([Tuesday], 0)   AS tuesday,
       COALESCE([Wednesday], 0) AS wednesday,
       COALESCE([Thursday], 0)  AS thursday,
       COALESCE([Friday], 0)    AS friday,
       COALESCE([Saturday], 0)  AS saturday,
       COALESCE([Sunday], 0)    AS sunday
FROM (
    SELECT customer_id, day_of_week, total_minutes_asleep
    FROM sleep_day
) src
PIVOT (
    SUM(total_minutes_asleep)
    FOR day_of_week IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
) p
ORDER BY customer_id;

/*
-- ==================================================================================
Problem: For each customer, display the following:
customer_id
date when they had the highest_weight(also mention weight in kg)
date when they had the highest_weight(also mention weight in kg)
-- ==================================================================================
*/

SELECT DISTINCT d.customer_id,
       COALESCE(FIRST_VALUE(dates || '  (' || weight_kg || ' kgs)') 
                OVER (PARTITION BY d.customer_id ORDER BY weight_kg DESC), 'NA') AS highest_weight_on,
       COALESCE(FIRST_VALUE(dates || '  (' || weight_kg || ' kgs)') 
                OVER (PARTITION BY d.customer_id ORDER BY weight_kg), 'NA') AS lowest_weight_on
FROM weight_log w
RIGHT JOIN daily_activity d ON d.customer_id = w.customer_id
ORDER BY highest_weight_on;


/*
-- ==================================================================================
Problem: Fetch the day when customers sleep the most.
-- ==================================================================================
*/
WITH most_sleep AS(
SELECT
	day_of_week
	, SUM(total_minutes_asleep) AS  total_sleep_time
	, RANK() OVER(ORDER BY SUM(total_minutes_asleep) DESC) AS rnk
FROM sleep_day
GROUP BY day_of_week
)
SELECT
	day_of_week
FROM most_sleep
WHERE rnk = 1;

/*
-- ==================================================================================
Problem: For each day of the week, determine the percentage of time customers spend 
lying on bed without sleeping.
-- ==================================================================================
*/
SELECT * FROM sleep_day; -- 410

SELECT
	day_of_week
	,(CAST(SUM(total_time_in_bed) AS DECIMAL) - CAST(SUM(total_minutes_asleep) AS DECIMAL)) AS time_in_bed_without_sleep
	,ROUND((CAST(SUM(total_minutes_asleep) AS DECIMAL) / CAST(SUM(total_time_in_bed) AS DECIMAL)) * 100,2) AS pct
FROM sleep_day
GROUP BY day_of_week
ORDER BY 3 DESC;

/*
-- ==================================================================================
Problem: Identify the most repeated day of week. Repeated day of week is when a day 
has been mentioned the most in entire database.
-- ==================================================================================
*/
WITH mention_of_day_from_all_tables AS (
SELECT day_of_week FROM daily_activity -- 940
UNION ALL
SELECT day_of_week FROM sleep_day -- 410
UNION ALL
SELECT day_of_week FROM weight_log -- 60
)
SELECT
	day_of_week
	, COUNT(1) AS repetition_count
FROM mention_of_day_from_all_tables
GROUP BY day_of_week
ORDER BY repetition_count DESC;

-- OR Getting to the actual answer with just top day
WITH all_days AS (
    -- Combine all day_of_week entries from all tables
    SELECT day_of_week FROM daily_activity
    UNION ALL
    SELECT day_of_week FROM weight_log
    UNION ALL
    SELECT day_of_week FROM sleep_day
),
day_counts AS (
    -- Count occurrences per day and rank them
    SELECT day_of_week,
           COUNT(1) AS occurrence,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rank_by_frequency
    FROM all_days
    GROUP BY day_of_week
)
SELECT day_of_week
FROM day_counts
WHERE rank_by_frequency = 1;


/*
-- ==================================================================================
Problem: Based on the given data, for each customer, identify the average distance (in kms) 
they walked on days when they took more than 6000 steps.
-- ==================================================================================
*/

SELECT customer_id, 
       ROUND(AVG(total_distance), 2) AS distance_kms
FROM daily_activity
WHERE total_steps > 6000
GROUP BY customer_id
ORDER BY distance_kms DESC;