-- Top Customers

SELECT
    c.customer
    ,ROUND(SUM(net_sales)/1000000,2) AS Net_Sales_in_Millions
FROM net_sales s
JOIN dim_customer c 
    ON c.customer_code = s.customer_code
WHERE fiscal_year = 2022
GROUP BY c.customer
ORDER BY Net_Sales_in_Millions DESC
LIMIT 5;