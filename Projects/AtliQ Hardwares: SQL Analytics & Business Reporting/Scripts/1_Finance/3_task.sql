/*******************************************************************************
 Generate a yearly report for Croma. 
 Report Fields: Fiscal Year & Total Gross Sales amount In that year from Croma
********************************************************************************/

SELECT
    YEAR (s.date) as Year
    ,ROUND(SUM(s.sold_quantity * g.gross_price), 2) AS Total_Gross_Sales
FROM fact_sales_monthly s
JOIN fact_gross_price g 
    ON s.product_code = g.product_code
    AND get_fiscal_year (s.date) = g.fiscal_year
WHERE customer_code = 90002002
GROUP BY YEAR (s.date)
ORDER BY Year
LIMIT 10;