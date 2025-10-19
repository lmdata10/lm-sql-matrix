WITH cte1 AS(
    SELECT
        c.customer
        ,ROUND(SUM(net_sales)/1000000,2) AS Net_Sales_in_Millions
    FROM net_sales s
    JOIN dim_customer c 
        ON c.customer_code = s.customer_code
    WHERE fiscal_year = 2021
    GROUP BY c.customer
)
SELECT 
    *
    ,Net_Sales_in_Millions*100/SUM(Net_Sales_in_Millions) OVER() AS NS_pct
FROM cte1
ORDER BY Net_Sales_in_Millions DESC
LIMIT 10;
    