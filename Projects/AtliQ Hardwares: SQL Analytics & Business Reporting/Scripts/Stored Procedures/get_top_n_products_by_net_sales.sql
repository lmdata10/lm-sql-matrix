CREATE PROCEDURE `get_top_n_products_by_net_sales` (
	in_market VARCHAR(45),
    in_fiscal_year INT,
    in_top_n INT  
)
BEGIN
	SELECT
    product,
    ROUND(SUM(net_sales)/1000000,2) AS Net_Sales_in_Millions
	FROM net_sales s
	WHERE fiscal_year = in_fiscal_year
		AND s.market = in_market
	GROUP BY product
	ORDER BY Net_Sales_in_Millions DESC
	LIMIT in_top_n;
END