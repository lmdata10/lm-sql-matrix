-- Create a NEW Table fact_act_estimates
CREATE Table
    fact_act_estimate (
        SELECT
            s.date AS date
            ,s.fiscal_year AS fiscal_year
            ,s.customer_code AS customer_code
            ,s.product_code AS product_code
            ,s.sold_quantity AS sold_quantity
            ,f.forecast_quantity AS forecast_quantity
        FROM fact_sales_monthly s
        LEFT JOIN fact_forecast_monthly f 
            USING (date, customer_code, product_code)
        UNION
        SELECT
            f.date AS date
            ,f.fiscal_year AS fiscal_year
            ,f.customer_code AS customer_code
            ,f.product_code AS product_code
            ,s.sold_quantity AS sold_quantity
            ,f.forecast_quantity AS forecast_quantity
        FROM fact_forecast_monthly f
        LEFT JOIN fact_sales_monthly s
            USING (date, customer_code, product_code)
);

UPDATE fact_act_estimate
SET sold_quantity = 0
WHERE sold_quantity IS NULL;

UPDATE fact_act_estimate
SET forecast_quantity = 0
WHERE forecast_quantity IS NULL;

-- Quick Glance
SELECT * FROM fact_act_estimate
LIMIT 10;