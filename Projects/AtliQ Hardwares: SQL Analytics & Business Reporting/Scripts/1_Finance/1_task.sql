/*******************************************************************************
Generate a report of individual product sales (aggregated on a monthly basis at the product code level)
for Croma India customer for FY =2021.
The report should have the following fields,
    1. Month
    2. Product Name
    3. Variant
    4. Sold Quantity
    5. Gross Price Per Item
    6. Gross Price Total
*******************************************************************************/

/*
The data we have is in Calendar year,and the request is to fetch the resukts for FY(fiscal year)
For our Company the Fiscal Year starts from September, so we'll have to convert the Calendar Year to Fiscal Year.
Now that I think about it, throught the project we'll need this Fiscal Year for many other queries, so,
why not create a User Defined Function for our Fiscal Year.
The same can be applied for Quarters
*/



SELECT 
    s.date AS Date
    ,s.product_code AS Product_Code
    ,p.product AS Product_Name
    ,p.variant AS Variant
    ,s.sold_quantity AS Quantity
    ,ROUND(g.gross_price, 2) AS Gross_Price_Per_Item
    ,ROUND(g.gross_price * s.sold_quantity, 2) AS Gross_Price_Total
FROM fact_sales_monthly s
JOIN dim_product p 
    ON s.product_code = p.product_code -- Performed a Join to pull Product Name and Variant.
JOIN fact_gross_price g 
    ON g.product_code = s.product_code -- Performed a Join to pull the Gross Price details.
    AND g.fiscal_year = get_fiscal_year(s.date)
WHERE customer_code = 90002002
    AND get_fiscal_year(DATE) = 2021
ORDER BY Gross_Price_Total DESC
LIMIT 25;


-- We can now export the Results in a .csv file and present the insights for Croma in FY=2021