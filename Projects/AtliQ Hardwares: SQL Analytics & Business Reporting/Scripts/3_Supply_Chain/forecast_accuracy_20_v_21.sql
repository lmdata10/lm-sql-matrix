CREATE temporary TABLE fa_2021
    WITH forecast_calc AS(
        SELECT
            e.customer_code
            ,c.customer AS Customer
            ,c.market AS Market
            ,SUM(sold_quantity) AS Total_Sold_Quantity
            ,SUM(forecast_quantity) AS Total_Forecast_Quantity
            ,SUM(forecast_quantity-sold_quantity) AS Net_Error
            ,ROUND(SUM(forecast_quantity-sold_quantity)*100 / SUM(forecast_quantity),2) AS Net_Error_pct
            ,SUM(ABS(forecast_quantity-sold_quantity)) AS Abs_Error
            ,ROUND(SUM(ABS(forecast_quantity-sold_quantity))*100 / SUM(forecast_quantity),2) AS Abs_Error_pct
        FROM fact_act_estimate e
        JOIN dim_customer c
            ON c.customer_code = e.customer_code
        WHERE fiscal_year = 2021
        GROUP BY customer_code
    )

SELECT 
    *
    ,IF(Abs_Error_pct > 100, 0, ROUND(100-Abs_Error_pct,2)) AS Forecast_Accuracy
FROM forecast_calc
ORDER BY Forecast_Accuracy DESC;

CREATE temporary TABLE fa_2020
    WITH forecast_calc AS(
        SELECT
            e.customer_code
            ,c.customer AS Customer
            ,c.market AS Market
            ,SUM(sold_quantity) AS Total_Sold_Quantity
            ,SUM(forecast_quantity) AS Total_Forecast_Quantity
            ,SUM(forecast_quantity-sold_quantity) AS Net_Error
            ,ROUND(SUM(forecast_quantity-sold_quantity)*100 / SUM(forecast_quantity),2) AS Net_Error_pct
            ,SUM(ABS(forecast_quantity-sold_quantity)) AS Abs_Error
            ,ROUND(SUM(ABS(forecast_quantity-sold_quantity))*100 / SUM(forecast_quantity),2) AS Abs_Error_pct
        FROM fact_act_estimate e
        JOIN dim_customer c
            ON c.customer_code = e.customer_code
        WHERE fiscal_year = 2020
        GROUP BY customer_code
    )

SELECT 
    *
    ,IF(Abs_Error_pct > 100, 0, ROUND(100-Abs_Error_pct,2)) AS Forecast_Accuracy
FROM forecast_calc
ORDER BY Forecast_Accuracy DESC;

SELECT
    f20.customer_code
    ,f20.customer AS Customer
    ,f20.market AS Market
    ,f20.Forecast_Accuracy AS Forecast_Accuracy_20
    ,f21.Forecast_Accuracy AS Forecast_Accuracy_21
FROM fa_2020 f20
JOIN fa_2021 f21 
    ON f21.customer_code = f20.customer_code
WHERE f21.Forecast_Accuracy < f20.Forecast_Accuracy
ORDER BY Forecast_Accuracy_20 DESC;
