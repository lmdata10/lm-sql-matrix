CREATE VIEW
    `gross_sales` AS
SELECT
    s.date,
    s.fiscal_year,
    s.customer_code,
    c.customer,
    s.market,
    s.product_code,
    s.product,
    s.variant,
    s.sold_quantity,
    s.gross_price_per_item,
    s.gross_price_total
FROM
    sales_preinvoice_discount s
    JOIN dim_customer c 
        ON c.customer_code = s.customer_code