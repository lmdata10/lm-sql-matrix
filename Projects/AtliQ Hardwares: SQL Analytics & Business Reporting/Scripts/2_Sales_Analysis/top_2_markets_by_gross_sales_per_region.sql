WITH cte1 AS (
    SELECT
        c.market
        ,c.region
        ,ROUND(SUM(s.sold_quantity*g.gross_price)/1000000,2) AS gross_sales_mln
    FROM fact_sales_monthly s
    JOIN fact_gross_price g
        ON s.product_code = g.product_code
        AND s.fiscal_year = g.fiscal_year
    JOIN dim_customer c 
        ON c.customer_code = s.customer_code
    WHERE s.fiscal_year = 2021
    GROUP BY c.market, c.region
),
cte2 AS (
    SELECT
        *
        ,DENSE_RANK() OVER (PARTITION BY region ORDER BY gross_sales_mln DESC) AS drnk
    FROM cte1
)
SELECT * 
FROM cte2 
WHERE drnk <= 2;