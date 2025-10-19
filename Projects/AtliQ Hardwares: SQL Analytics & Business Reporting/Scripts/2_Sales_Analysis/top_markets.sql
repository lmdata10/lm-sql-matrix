-- Top Markets

SELECT
    market
    ,ROUND(SUM(net_sales)/1000000,2) AS Net_Sales_in_Millions
FROM net_sales
WHERE fiscal_year = 2022
GROUP BY market
ORDER BY Net_Sales_in_Millions DESC
LIMIT 5;
