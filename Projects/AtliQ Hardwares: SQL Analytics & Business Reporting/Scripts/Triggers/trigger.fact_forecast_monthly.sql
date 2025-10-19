CREATE DEFINER=`root`@`localhost` TRIGGER `fact_forecast_monthly_AFTER_INSERT`AFTER INSERT ON `fact_forecast_monthly` FOR EACH ROW BEGIN
	INSERT INTO fact_act_estimate
		(date, product_code, customer_code, forecast_quanity)
	VALUES (
        NEW.date
        ,NEW.product_code
        ,NEW.customer_code
        ,NEW.forecast_quantity
    ) 
    ON DUPLICATE KEY
		UPDATE forecast_quantity = VALUES(forecast_quantity);
END