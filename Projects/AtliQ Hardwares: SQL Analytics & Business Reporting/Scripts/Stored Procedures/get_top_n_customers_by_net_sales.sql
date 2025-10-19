CREATE PROCEDURE `get_top_n_customers_by_net_sales` (
	in_market VARCHAR(45),
    in_fiscal_year INT,
    in_top_n INT  
)
BEGIN
	SELECT
    c.customer,
    ROUND(SUM(net_sales)/1000000,2) AS Net_Sales_in_Millions
	FROM net_sales s
	JOIN dim_customer c 
		ON c.customer_code = s.customer_code
	WHERE fiscal_year = in_fiscal_year
		AND s.market = in_market
	GROUP BY c.customer
	ORDER BY Net_Sales_in_Millions DESC
	LIMIT in_top_n;
END