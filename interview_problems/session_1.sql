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


-- ======================================================================
-- INTERVIEW PROBLEM 2
-- ======================================================================

