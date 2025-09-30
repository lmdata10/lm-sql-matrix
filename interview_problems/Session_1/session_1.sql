-- ======================================================================
-- INTERVIEW PROBLEM 1 
-- ======================================================================
/*
-- StrataScratch - [LINK](https://platform.stratascratch.com/coding/10285-acceptance-rate-by-date?python=&code_type=1)

Q. Acceptance Rate By Date

What is the overall friend acceptance rate by date?
	- Your output should have the rate of acceptances by the date the request was sent.
	- Order by the earliest date to latest.

Assume that each friend request starts by a user sending (i.e., user_id_sender)
	- a friend request to another user (i.e., user_id_receiver) that's logged in
	- the table with action = 'sent'. If the request is accepted, the table
	- logs action = 'accepted'. If the request is not accepted, no record of
	- action = 'accepted' is logged
*/

-- INSERT SCRIPT

-- Create table
CREATE TABLE fb_friend_requests (
    user_id_sender   VARCHAR(20),
    user_id_receiver VARCHAR(20),
    date             DATE,
    action           VARCHAR(20)
);

-- Insert sample data
INSERT INTO fb_friend_requests VALUES 
('ad4943sdz',      '948ksx123d',   '2020-01-04', 'sent'),
('ad4943sdz',      '948ksx123d',   '2020-01-06', 'accepted'),
('dfdfxf9483',     '9djjjd9283',   '2020-01-04', 'sent'),
('dfdfxf9483',     '9djjjd9283',   '2020-01-15', 'accepted'),
('ffdfff4234234',  'lpjzjdi4949',  '2020-01-06', 'sent'),
('fffkfld9499',    '993lsldidif',  '2020-01-06', 'sent'),
('fffkfld9499',    '993lsldidif',  '2020-01-10', 'accepted'),
('fg503kdsdd',     'ofp049dkd',    '2020-01-04', 'sent'),
('fg503kdsdd',     'ofp049dkd',    '2020-01-10', 'accepted'),
('hh643dfert',     '847jfkf203',   '2020-01-04', 'sent'),
('r4gfgf2344',     '234ddr4545',   '2020-01-06', 'sent'),
('r4gfgf2344',     '234ddr4545',   '2020-01-11', 'accepted');

SELECT *
FROM fb_friend_requests;

-- Problem Breakdown
-- 1) Find total requests that were `sent` each day
-- 2) Find total requests that were `accepted` each day
-- 3) Calculate the rate of acceptance = total accepted / total sent

-- 1) Find total requests that were `sent` each day
WITH sent_requests AS(
SELECT
    date
    , COUNT(action) AS sent_count
FROM fb_friend_requests
WHERE action = 'sent'
GROUP BY date
)
-- 2) Find total requests that were `accepted` each day

, accepted_requests AS(
SELECT
    sent_rq.date
    , COUNT(sent_rq.action) AS accepted_count
FROM fb_friend_requests sent_rq
JOIN fb_friend_requests accptd
    ON sent_rq.user_id_sender = accptd.user_id_sender
        AND sent_rq.user_id_receiver = accptd.user_id_receiver
WHERE sent_rq.action = 'sent' AND accptd.action = 'accepted'
GROUP BY sent_rq.date
)

SELECT
    s.DATE
    , CONCAT(CAST(ROUND(( CAST(a.accepted_count AS DECIMAL) / CAST(s.sent_count AS DECIMAL)),2) * 100 AS INT), '%') AS acceptance_rate
FROM sent_requests s
JOIN accepted_requests a 
    ON s.date = a.date;

/*
-- ======================================================================
-- INTERVIEW PROBLEM 2
-- ======================================================================

Find the popularity percentage for each user on Meta/Facebook.
The popularity percentage is defined as the total number of friends the user has divided by the
total number of users on the platform, then converted into a percentage by multiplying by 100.
Output each user along with their popularity percentage. Order records in ascending order by user id.
*/

drop table if exists facebook_friends;
create table facebook_friends
    (
        user1       int,
        user2       int
    );

insert into facebook_friends values (2,1);
insert into facebook_friends values (1,3);
insert into facebook_friends values (4,1);
insert into facebook_friends values (1,5);
insert into facebook_friends values (1,6);
insert into facebook_friends values (2,6);
insert into facebook_friends values (7,2);
insert into facebook_friends values (8,3);
insert into facebook_friends values (3,9);

SELECT * FROM facebook_friends;

/*

Let's Try to understand the question by replacing values in data in our way

user 1          user2
David           Josh
Joe             Rob
David           Rob
Rob             Lexi
Lexi            David
Shiela          Joe
Lexi            Shiela

Popularity % of Lexi    = (friends count / total users) * 100
                        = (2 / 6) * 100
                        = 0.33 * 100
                        = 33% is the popularity % of Lexi
*/

WITH all_users AS(
    -- Combine all users from both columns into a single list
    SELECT user1 AS user_id FROM facebook_friends
    UNION ALL
    SELECT user2 AS user_id FROM facebook_friends
)
,total_users AS(
    -- Find the total count of unique users on the platform
    SELECT  COUNT(DISTINCT user_id) AS total_users_count FROM all_users
)
, frnd_count AS(
    -- Count the total number of friends for each user.
    -- Since the table has (u1, u2) as one friendship row, counting the
    -- total appearances of a user_id in the combined list correctly
    -- gives the total number of friends.
    SELECT
        user_id
        , COUNT(user_id) AS frnd_count
    FROM all_users
    GROUP BY user_id
)
-- Calculate the popularity percentage
SELECT 
    fc.user_id
    , ROUND((CAST(fc.frnd_count AS FLOAT) / tu.total_users_count) * 100, 2) AS popularity
FROM frnd_count fc
CROSS JOIN total_users tu
ORDER BY user_id;


/*
-- ======================================================================
-- INTERVIEW PROBLEM 3
-- ======================================================================
QUESTION : Salaries Differences
-- Write a query that calculates the difference between the highest salaries 
found in the marketing and engineering departments. Output just the absolute difference in salaries.

*/

-- CTE Solution
SELECT * FROM db_employee;
SELECT * FROM db_dept;

WITH department_sal AS(
SELECT
    dd.department
    , MAX(de.salary) AS max_salary
FROM db_employee de
JOIN db_dept dd
    ON de.department_id = dd.id
WHERE dd.department IN ('marketing', 'engineering')
GROUP BY dd.department
)
SELECT 
    ABS((m.max_salary - e.max_salary)) AS abs_difference
FROM department_sal e
CROSS JOIN department_sal m
WHERE m.department = 'marketing'
    AND e.department = 'engineering'

-- CASE WHEN
SELECT
    -- Use MAX with a CASE statement to get the max salary for each specific department
    ABS(
        MAX(CASE WHEN dd.department = 'engineering' THEN de.salary END) -
        MAX(CASE WHEN dd.department = 'marketing' THEN de.salary END)
    ) AS abs_difference
FROM db_employee de
JOIN db_dept dd
    ON de.department_id = dd.id
WHERE dd.department IN ('engineering', 'marketing');


/*
-- ======================================================================
-- INTERVIEW PROBLEM 4
-- ======================================================================
QUESTION : Finding User Purchases
-- Write a query that'll identify returning active users. A returning active user 
-- is a user that has made a second purchase within 7 days of any other of their 
-- purchases. Output a list of user_ids of these returning active users.

*/

-- Solution using SELF JOIN 

SELECT DISTINCT t1.user_id
FROM amazon_transactions t1
JOIN amazon_transactions t2
    ON t1.user_id = t2.user_id 
   AND t1.id <> t2.id
   AND t2.created_at BETWEEN t1.created_at 
                         AND DATEADD(DAY, 7, t1.created_at)
--WHERE t1.user_id = 100
ORDER BY t1.user_id;

-- ---------------------------------------------------------------------

-- Solution using Window Function LAG()

WITH RankedPurchases AS (
SELECT
    user_id
    ,created_at
    -- Use the LAG window function to retrieve the date of the previous transaction
    ,LAG(created_at) OVER (PARTITION BY user_id ORDER BY created_at) AS previous_purchase_date
FROM amazon_transactions
)
SELECT 
    DISTINCT user_id
FROM RankedPurchases
WHERE
    -- Check if the time difference between the current purchase and the previous
    -- one is within the 7-day window.
    DATEDIFF(day, previous_purchase_date, created_at) <= 7
ORDER BY user_id;

/*
-- ======================================================================
-- INTERVIEW PROBLEM 5
-- ======================================================================
QUESTION: User Email Labels
Find the number of emails received by each user under each built-in email label.
The email labels are: 'Promotion', 'Social', and 'Shopping'. 
Output the user along with the number of promotion, social, and shopping mails count

*/

SELECT TOP 10 * FROM google_gmail_emails;
SELECT TOP 10 * FROM google_gmail_labels;
SELECT 
    e.to_user AS received_by_user,
    SUM(CASE WHEN l.label = 'Promotion' THEN 1 ELSE 0 END) AS promotion_emails,
    SUM(CASE WHEN l.label = 'Social' THEN 1 ELSE 0 END) AS social_emails,
    SUM(CASE WHEN l.label = 'Shopping' THEN 1 ELSE 0 END) AS shopping_emails
FROM google_gmail_emails e
JOIN google_gmail_labels l
    ON e.id = l.email_id
WHERE l.label IN ('Promotion', 'Social', 'Shopping')
GROUP BY e.to_user
ORDER BY e.to_user;