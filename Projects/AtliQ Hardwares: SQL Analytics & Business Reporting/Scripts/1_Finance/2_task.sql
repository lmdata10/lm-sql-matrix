/*******************************************************************************
Develop a monthly aggregate gross sales report for Croma Customer to monitor their sales contributions and 
effectively manage our relationship.
Report Fields: Month & Total Gross Sales Amount to Croma for the Month
*******************************************************************************/

SELECT 
    s.date
    ,ROUND(SUM(s.sold_quantity * g.gross_price),2) AS Total_Gross_Sales
FROM fact_sales_monthly s
JOIN fact_gross_price g 
    ON g.product_code = s.product_code
    AND g.fiscal_year = get_fiscal_year(s.date)
WHERE customer_code = 90002002
GROUP BY s.date
ORDER BY Total_Gross_Sales DESC
LIMIT 10;