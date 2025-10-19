CREATE VIEW `sales_preinvoice_discount` AS
        SELECT
            s.date,
            s.fiscal_year,
            s.customer_code,
            c.market,
            s.product_code,
            p.product,
            p.variant,
            s.sold_quantity,
            ROUND(g.gross_price, 2) AS gross_price_per_item,
            ROUND(g.gross_price * s.sold_quantity, 2) AS gross_price_total,
            pid.pre_invoice_discount_pct
        FROM
            fact_sales_monthly s
            JOIN dim_customer c 
                ON c.customer_code = s.customer_code
            JOIN dim_product p 
                ON s.product_code = p.product_code
            JOIN dim_date d 
                ON d.calendar_date = s.date
            JOIN fact_gross_price g 
                ON g.product_code = s.product_code
                AND g.fiscal_year = d.fiscal_year
            JOIN fact_pre_invoice_deductions pid 
                ON s.customer_code = pid.customer_code
                AND d.fiscal_year = pid.fiscal_year
        WHERE
            d.fiscal_year = 2021