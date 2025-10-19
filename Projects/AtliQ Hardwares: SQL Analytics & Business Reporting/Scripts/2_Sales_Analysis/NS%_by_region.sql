WITH cte1 AS(
    SELECT
        c.customer
        ,c.region
        ,ROUND(SUM(net_sales)/1000000,2) AS Net_Sales_in_Millions
    FROM net_sales ns
    JOIN dim_customer c 
        ON c.customer_code=ns.customer_code
    WHERE fiscal_year = 2021
    GROUP BY c.customer,c.region
)
SELECT 
    *
    ,Net_Sales_in_Millions*100/SUM(Net_Sales_in_Millions) OVER(PARTITION BY region) AS NS_pct
FROM cte1
ORDER BY region, Net_Sales_in_Millions DESC;

