# Credit Card Transactions Analysis: SQL Report

This document presents the SQL queries and their resulting data points derived from the credit card transaction tables (`CardBase`, `CustomerBase`, `FraudBase`, and `TransactionBase`).

## Data Check

![ERD](/=images/ERD_CCT.png)

Initial count of records per table:

|Table|Count|
|---|---|
|`cardbase`|500|
|`customerbase`|5674|
|`fraudbase`|109|
|`transactionbase`|10000|

## 1. High-Value Transactions

**Problem:** How many customers have executed transactions over $49,000?

```SQL
SELECT 
    COUNT(DISTINCT c.Cust_ID) AS Count_of_cx
FROM TransactionBase t
JOIN CardBase c ON t.Credit_Card_ID = c.card_number
WHERE t.transaction_value > 49000
```

|Count_of_cx|
|---|
|166|

## 2. Premium Eligibility

**Problem:** What kind of customer segments can qualify for a **Premium credit card**?

```SQL
SELECT 
   DISTINCT cb.Customer_Segment
FROM CustomerBase cb 
JOIN CardBase crd ON crd.Cust_ID = cb.Cust_ID
WHERE crd.Card_Family = 'Premium';
```

|Customer_Segment|
|---|
|Gold|
|Diamond|
|Platinum|

## 3. Fraud Range (Credit Limit)

**Problem:** Identify the range of credit limits (minimum and maximum) of customers who have been involved in fraudulent transactions.

```SQL
SELECT
   MAX(Credit_Limit) AS max_limit
   , MIN(Credit_Limit) AS min_limit
FROM TransactionBase tb
JOIN FraudBase fb ON tb.Transaction_ID = fb.Transaction_ID
JOIN CardBase cb ON cb.Card_Number = tb.Credit_Card_ID
```

|max_limit|min_limit|
|---|---|
|879000|2000|

## 4. Fraud by Age & Card Type

**Problem:** What is the average age of customers involved in fraudulent transactions, broken down by card type?

```SQL
SELECT
   cb.Card_Family
   , AVG(cxb.Age) AS avg_age
FROM TransactionBase tb
JOIN FraudBase fb ON tb.Transaction_ID = fb.Transaction_ID
JOIN CardBase cb ON cb.Card_Number = tb.Credit_Card_ID
JOIN CustomerBase cxb ON cxb.Cust_ID = cb.Cust_ID
GROUP BY cb.Card_Family;
```

|Card_Family|avg_age|
|---|---|
|Premium|35|
|Gold|36|
|Platinum|32|

## 5. Fraud by Time

**Problem:** Identify the month when the highest number of fraudulent transactions occurred.

```SQL
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
```

|month_name|
|---|
|September|

## 6. Top Legitimate Spender

**Problem:** Identify the customer who has the highest total transaction value, excluding any fraudulent transactions.

```SQL
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
```

|cust_id|total_transaction_value|
|---|---|
|CC91963|1448581|

## 7. Inactive Customers

**Problem:** Find customers who are in the customer base but have not performed a single transaction (not even a fraudulent one).

```SQL
SELECT
   DISTINCT cxb.Cust_ID
FROM CustomerBase cxb
LEFT JOIN CardBase cb
   ON cxb.Cust_ID = cb.Cust_ID
LEFT JOIN Transactionbase tb
   ON cb.Card_Number = tb.Credit_Card_ID
WHERE tb.Transaction_ID IS NULL
```

|Count of Inactive Customers|
|---|
|5192|

## 8. Credit Limit Extremes

**Problem:** What is the highest and lowest credit limit assigned to each card type?

```SQL
SELECT
   card_family
   , MIN(Credit_Limit) AS min_limit
   , MAX(Credit_Limit) AS max_limit
FROM CardBase
GROUP BY card_family
```

|card_family|min_limit|max_limit|
|---|---|---|
|Gold|2000|50000|
|Platinum|51000|200000|
|Premium|108000|899000|

## 9. Total Transaction Value by Age Group

**Problem:** What is the total value of transactions done by customers in the following age brackets: 0-20 yrs, 20-30 yrs, 30-40 yrs, 40-50 yrs, and 50+ yrs?

```SQL
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
```

|age_group|total_transaction_value|
|---|---|
|0-20 yrs|5553480|
|20-30 yrs|78340569|
|30-40 yrs|75549759|
|40-50 yrs|88143605|

## 10. Card Type Transaction Summary (Non-Fraudulent)

**Problem:** Which card type has performed the highest number of transactions and the highest total transaction value, excluding any fraudulent transactions?

```SQL
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
```

|card_family|transaction_count|total_transaction_value|metric|
|---|---|---|---|
|Premium|4054|100002750|Highest number of transactions|
|Premium|4054|100002750|Highest total transaction value|

