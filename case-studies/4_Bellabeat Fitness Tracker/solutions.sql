
SELECT * FROM daily_activity; -- 940
SELECT * FROM sleep_day; -- 410
SELECT * FROM weight_log; -- 60

/* Identify the day of the week when the customers are most active and least 
active. Active is determined based on the no of steps.
*/
WITH CTE AS(
SELECT
    day_of_week
    , SUM(total_steps) AS total_steps
FROM daily_activity
GROUP BY day_of_week
)

SELECT
    day_of_week AS most_active_day
    ,MAX(total_steps) AS total_steps_max
FROM cte
GROUP BY cte.day_of_week
UNION ALL
SELECT
    day_of_week AS least_active_day
    ,MIN(total_steps) AS total_steps_min
FROM cte
GROUP BY cte.day_of_week


/*Identify the customer who has the most effective sleep. Effective sleep is 
determined based on is customer spent most of the time in bed sleeping. */

-- Identify customers with no sleep record.

-- Fetch all customers whose daily activity, sleep and weight logs are all present.

/* For each customer, display the total hours they slept for each day of the week. 
Your output should contains 8 columns, first column is the customer id and the 
next 7 columns are the day of the week (like monday, tuesday etc)
*/

/*
For each customer, display the following:
customer_id
date when they had the highest_weight(also mention weight in kg)
date when they had the highest_weight(also mention weight in kg)
*/

-- Fetch the day when customers sleep the most.

/* For each day of the week, determine the percentage of time customers spend 
lying on bed without sleeping. */


/*
Identify the most repeated day of week. Repeated day of week is when a day 
has been mentioned the most in entire database.
*/


/*
Based on the given data, identify the average kms a customer walks based on 
6000 steps.
*/
