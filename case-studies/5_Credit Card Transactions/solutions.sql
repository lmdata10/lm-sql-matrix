--  Credit Card Transactions Analysis Questions
SELECT * FROM cardbase; -- 500 
SELECT * FROM customerbase; -- 5674
SELECT * FROM fraudbase; -- 109
SELECT * FROM transactionbase; -- 10000

/*
-- ===================================================================================================
1. High-value transactions
   - How many customers have done transactions over 49,000?
-- ===================================================================================================
*/

SELECT 
    COUNT(DISTINCT c.Cust_ID) AS Count_of_cx
FROM TransactionBase t
JOIN CardBase c ON t.Credit_Card_ID = c.card_number
WHERE t.transaction_value > 49000

/*
-- ===================================================================================================
2. Premium eligibility
   - What kind of customers can get a **Premium credit card**?
-- ===================================================================================================
*/

SELECT 
   DISTINCT cb.Customer_Segment
FROM CustomerBase cb 
JOIN CardBase crd ON crd.Cust_ID = cb.Cust_ID
WHERE crd.Card_Family = 'Premium';

/*
-- ===================================================================================================
3. Fraud range (Credit Limit)  
   - Identify the range of credit limits of customers who have done fraudulent transactions.
-- ===================================================================================================
*/

SELECT
   MAX(Credit_Limit) AS max_limit
   , MIN(Credit_Limit) AS min_limit
FROM TransactionBase tb
JOIN FraudBase fb ON tb.Transaction_ID = fb.Transaction_ID
JOIN CardBase cb ON cb.Card_Number = tb.Credit_Card_ID

/*
-- ===================================================================================================
4. Fraud by age & card type 
   - What is the average age of customers involved in fraudulent transactions, broken down by card type?
-- ===================================================================================================
*/

SELECT
   cb.Card_Family
   , AVG(cxb.Age) AS avg_age
FROM TransactionBase tb
JOIN FraudBase fb ON tb.Transaction_ID = fb.Transaction_ID
JOIN CardBase cb ON cb.Card_Number = tb.Credit_Card_ID
JOIN CustomerBase cxb ON cxb.Cust_ID = cb.Cust_ID
GROUP BY cb.Card_Family;

/*
-- ===================================================================================================
5. Fraud by time
   - Identify the month when the highest number of fraudulent transactions occurred.
-- ===================================================================================================
*/

-- Approach 1 (Simple)

SELECT TOP 1 
       DATENAME(MONTH, tb.transaction_date) AS mon,
       COUNT(1) AS no_of_fraud_trns
FROM Transactionbase tb
JOIN Fraudbase fb
     ON fb.transaction_id = tb.transaction_id
GROUP BY DATENAME(MONTH, tb.transaction_date)
ORDER BY no_of_fraud_trns DESC;

-- Approach 2
-- Fraud by month (tie-safe)
WITH fraud_counts AS (
    SELECT 
        DATENAME(MONTH, tb.transaction_date) AS month_name,
        COUNT(fb.transaction_id) AS fraud_transactions
    FROM TransactionBase tb
    JOIN FraudBase fb 
        ON tb.transaction_id = fb.transaction_id
    GROUP BY DATENAME(MONTH, tb.transaction_date)
)
SELECT month_name
FROM fraud_counts
WHERE fraud_transactions = (SELECT MAX(fraud_transactions) FROM fraud_counts);


-- We can also solve it using RANK() or DENSE_RANK() Window Functions, but the above method in approach 2 could be more performant.


/*
-- ===================================================================================================
6. Top legitimate spender
   - Identify the customer who has the highest total transaction value without any fraudulent transactions.
-- ===================================================================================================
*/
WITH cte AS(
SELECT
   cb.Cust_ID
   ,SUM(tb.Transaction_Value) AS total_transaction_value
FROM Transactionbase tb
LEFT JOIN Fraudbase fb
      ON fb.transaction_id = tb.transaction_id
JOIN CardBase cb 
      ON cb.Card_Number = tb.Credit_Card_ID
WHERE fb.Fraud_Flag IS NULL
GROUP BY cb.Cust_ID
)
SELECT
   cust_id
   , total_transaction_value
FROM cte
WHERE total_transaction_value = (SELECT MAX(total_transaction_value) FROM cte)



/*
-- ===================================================================================================
7. Inactive customers 
   - Find customers who have not done a single transaction.
-- ===================================================================================================
*/

SELECT
   DISTINCT cxb.Cust_ID
FROM CustomerBase cxb
LEFT JOIN CardBase cb
   ON cxb.Cust_ID = cb.Cust_ID
LEFT JOIN Transactionbase tb
   ON cb.Card_Number = tb.Credit_Card_ID
WHERE tb.Transaction_ID IS NULL

/*
-- ===================================================================================================
8. Credit limit extremes  
   - What is the highest and lowest credit limit given to each card type?
-- ===================================================================================================
*/

SELECT
   card_family
   , MIN(Credit_Limit) AS min_limit
   , MAX(Credit_Limit) AS max_limit
FROM CardBase
GROUP BY card_family

/*
-- ===================================================================================================
9. Total transaction value by age group
   - What is the total value of transactions done by customers in the following age brackets: 
   - 0-20 yrs, 20-30 yrs, 30-40 yrs, 40-50 yrs, and 50+ yrs?
-- ===================================================================================================
*/


SELECT
   CASE
      WHEN cb.Age BETWEEN 0 AND 20 THEN '0-20 yrs'
      WHEN cb.Age BETWEEN 20 AND 30 THEN '20-30 yrs'
      WHEN cb.Age BETWEEN 30 AND 40 THEN '30-40 yrs'
      WHEN cb.Age BETWEEN 40 AND 50 THEN '40-50 yrs'
      ELSE '50+ yrs'
   END AS age_group
   , SUM(tb.Transaction_Value) total_transaction_value
FROM CustomerBase cb
JOIN CardBase crd 
   ON crd.Cust_ID = cb.Cust_ID
JOIN Transactionbase tb
   ON crd.Card_Number = tb.Credit_Card_ID
GROUP BY
   CASE
      WHEN cb.Age BETWEEN 0 AND 20 THEN '0-20 yrs'
      WHEN cb.Age BETWEEN 20 AND 30 THEN '20-30 yrs'
      WHEN cb.Age BETWEEN 30 AND 40 THEN '30-40 yrs'
      WHEN cb.Age BETWEEN 40 AND 50 THEN '40-50 yrs'
      ELSE '50+ yrs'
   END
ORDER BY age_group;

-- Same Solution but displayed in Columns
SELECT 
    SUM(CASE WHEN cxb.age >= 0  AND cxb.age <= 20 THEN tb.transaction_value ELSE 0 END) AS trns_value_0_to_20,
    SUM(CASE WHEN cxb.age > 20 AND cxb.age <= 30 THEN tb.transaction_value ELSE 0 END) AS trns_value_20_to_30,
    SUM(CASE WHEN cxb.age > 30 AND cxb.age <= 40 THEN tb.transaction_value ELSE 0 END) AS trns_value_30_to_40,
    SUM(CASE WHEN cxb.age > 40 AND cxb.age <= 50 THEN tb.transaction_value ELSE 0 END) AS trns_value_40_to_50,
    SUM(CASE WHEN cxb.age > 50 THEN tb.transaction_value ELSE 0 END) AS trns_value_greater_than_50
FROM TransactionBase tb
JOIN CardBase cb ON tb.credit_card_id = cb.card_number
JOIN CustomerBase cxb ON cb.cust_id = cxb.cust_id;


/*
-- ===================================================================================================
10. Card type transaction summary
   - Which card type has performed the highest number of transactions and the highest total transaction value, 
   - excluding any fraudulent transactions?
   -- ===================================================================================================
*/

WITH cte AS (
    SELECT
        cb.card_family
        ,COUNT(tb.transaction_id) AS transaction_count
        ,SUM(tb.transaction_value) AS total_transaction_value
        ,RANK() OVER (ORDER BY COUNT(tb.transaction_id) DESC) AS rnk_count
        ,RANK() OVER (ORDER BY SUM(tb.transaction_value) DESC) AS rnk_value
    FROM CardBase cb
    JOIN TransactionBase tb 
         ON tb.credit_card_id = cb.card_number
    LEFT JOIN FraudBase fb 
         ON fb.transaction_id = tb.transaction_id
    WHERE fb.transaction_id IS NULL   -- exclude fraud
    GROUP BY cb.card_family
)
SELECT card_family, transaction_count, total_transaction_value, 'Highest number of transactions' AS metric
FROM cte
WHERE rnk_count = 1

UNION ALL

SELECT card_family, transaction_count, total_transaction_value, 'Highest total transaction value' AS metric
FROM cte
WHERE rnk_value = 1;
