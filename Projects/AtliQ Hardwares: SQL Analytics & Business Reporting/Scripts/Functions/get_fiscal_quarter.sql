CREATE DEFINER=`root`@`localhost` FUNCTION `get_fiscal_quarter`(
	calendar_date date
) RETURNS char(2) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	DECLARE m TINYINT;
    DECLARE qtr CHAR(2);
    SET m = month(calendar_date);
	CASE
		WHEN m in (9,10,11) THEN
			SET qtr = 'Q1';
		WHEN m in (12,1,2) THEN
			SET qtr = 'Q2';
		WHEN m in (2,3,4) THEN
			SET qtr = 'Q3';
		ELSE
			SET qtr = 'Q4';
	END CASE;
RETURN qtr;
END