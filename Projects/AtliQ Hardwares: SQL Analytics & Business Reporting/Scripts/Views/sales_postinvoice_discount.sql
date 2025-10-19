CREATE VIEW
    `sales_postinvoice_discount` AS
SELECT
    s.date,
    s.fiscal_year,
    s.customer_code,
    s.market,
    s.product_code,
    s.product,
    s.variant,
    s.sold_quantity,
    s.gross_price_total,
    s.pre_invoice_discount_pct,
    (s.gross_price_total - s.pre_invoice_discount_pct * s.gross_price_total) as net_invoice_sales,
    (pod.discounts_pct + pod.other_deductions_pct) as post_invoice_discount_pct
FROM
    sales_preinvoice_discount s
    JOIN fact_post_invoice_deductions pod
        ON s.customer_code = pod.customer_code
        AND s.product_code = pod.product_code
        AND s.date = pod.date