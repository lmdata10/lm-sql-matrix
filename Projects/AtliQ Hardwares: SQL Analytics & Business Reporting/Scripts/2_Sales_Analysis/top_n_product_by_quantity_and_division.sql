WITH cte1 AS (
    SELECT
        p.division
        ,p.product
        ,SUM(s.sold_quantity) AS total_qty
    FROM fact_sales_monthly s
    JOIN dim_product p
        ON p.product_code = s.product_code
    WHERE s.fiscal_year = 2021
    GROUP BY p.division, p.product
),
cte2 AS (
    SELECT
        *
        ,DENSE_RANK() OVER (PARTITION BY division ORDER BY total_qty DESC) AS drnk
    FROM cte1
)
SELECT * 
FROM cte2 
WHERE drnk <= 3;