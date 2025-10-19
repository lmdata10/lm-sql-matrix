CREATE DEFINER=`root`@`localhost` TRIGGER `fact_sales_monthly_AFTER_INSERT` AFTER INSERT ON `fact_sales_monthly` FOR EACH ROW BEGIN
	INSERT INTO fact_act_estimate
		(date, product_code, customer_code, sold_quanity)
	VALUES (
        NEW.date
        ,NEW.product_code
        ,NEW.customer_code
        ,NEW.sold_quantity
    ) 
    ON DUPLICATE KEY
		UPDATE sold_quanity = VALUES(sold_quanity);
END

-- You can verify it by
SHOW TRIGGERS