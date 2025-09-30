
/*
-- ================================================================
-- INSER SCRIPT
-- ================================================================

create table products
(
	product_code			varchar(20) primary key,
	product_name			varchar(100),
	price					float,
	quantity_remaining		int,
	quantity_sold			int
);

create table sales
(
	order_id			int identity(1,1) primary key,
	order_date			date,
	product_code		varchar(20) references products(product_code),
	quantity_ordered	int,
	sale_price			float
);

insert into products (product_code,product_name,price,quantity_remaining,quantity_sold)
	values ('P1', 'iPhone 13 Pro Max', 1200, 5, 195);
insert into products (product_code,product_name,price,quantity_remaining,quantity_sold)
	values ('P2', 'AirPods Pro', 279, 10, 90);
insert into products (product_code,product_name,price,quantity_remaining,quantity_sold)
	values ('P3', 'MacBook Pro 16', 5000, 2, 48);
insert into products (product_code,product_name,price,quantity_remaining,quantity_sold)
	values ('P4', 'iPad Air', 650, 1, 9);

insert into sales (order_date,product_code,quantity_ordered,sale_price)
	values (convert(datetime,'10-01-2022',105), 'P1', 100, 120000);
insert into sales (order_date,product_code,quantity_ordered,sale_price)
	values (convert(datetime,'20-01-2022',105), 'P1', 50, 60000);
insert into sales (order_date,product_code,quantity_ordered,sale_price)
	values (convert(datetime,'05-02-2022',105), 'P1', 45, 540000);
insert into sales (order_date,product_code,quantity_ordered,sale_price)
	values (convert(datetime,'15-01-2022',105), 'P2', 50, 13950);
insert into sales (order_date,product_code,quantity_ordered,sale_price)
	values (convert(datetime,'25-03-2022',105), 'P2', 40, 11160);
insert into sales (order_date,product_code,quantity_ordered,sale_price)
	values (convert(datetime,'25-02-2022',105), 'P3', 10, 50000);
insert into sales (order_date,product_code,quantity_ordered,sale_price)
	values (convert(datetime,'15-03-2022',105), 'P3', 10, 50000);
insert into sales (order_date,product_code,quantity_ordered,sale_price)
	values (convert(datetime,'25-03-2022',105), 'P3', 20, 100000);
insert into sales (order_date,product_code,quantity_ordered,sale_price)
	values (convert(datetime,'21-04-2022',105), 'P3', 8, 40000);
insert into sales (order_date,product_code,quantity_ordered,sale_price)
	values (convert(datetime,'27-04-2022',105), 'P4', 9, 5850);

**************************************************************************/


/**************************************************************************
TASK: Build a script which keeps track of every product sale
**************************************************************************/

SELECT * FROM products;
SELECT * FROM sales;


/**************************************************************************
UDF (User Defined Function)
**************************************************************************/

CREATE OR ALTER FUNCTION fn_check_product (@p_product_name VARCHAR(30), @p_quantity INT)
RETURNS BIT -- In SQL server BIT is used instead of BOOLEAN (TURE & FALSE)
AS 
BEGIN
    DECLARE @v_cnt INT;
    DECLARE @v_result BIT; -- BIT (0 = FALSE & 1 = TRUE)

    SELECT @v_cnt = COUNT(1)
    FROM products
    WHERE product_name = @p_product_name
      AND quantity_remaining >= @p_quantity;

    IF @v_cnt = 0 
        SET @v_result = 0;
    ELSE 
        SET @v_result = 1;

    RETURN @v_result;
END;

-- Test it
SELECT dbo.fn_check_product('AirPods Pro', 9);



/**************************************************************************
Stored Procedure
**************************************************************************/

CREATE OR ALTER PROCEDURE pr_product_sale (@p_product_name VARCHAR(30), @p_quantity INT)
AS 
BEGIN
    DECLARE
        @v_prod_code   VARCHAR(30),
        @v_price       INT,
        @v_check       BIT;

    SELECT @v_check = dbo.fn_check_product(@p_product_name, @p_quantity);

    IF @v_check = 1 
    BEGIN 
        SELECT @v_prod_code = product_code, 
               @v_price = price
        FROM products
        WHERE product_name = @p_product_name;

        INSERT INTO sales 
        VALUES (CAST(GETDATE() AS DATE), @v_prod_code, @p_quantity, @v_price * @p_quantity);

        UPDATE products
        SET quantity_remaining = quantity_remaining - @p_quantity,
            quantity_sold = quantity_sold + @p_quantity
        WHERE product_code = @v_prod_code;

        PRINT('Product sold successfully!');
    END;
    ELSE 
        PRINT('Failure: Out of Stock!');
END;

-- Test it
EXEC pr_product_sale 'MacBook Pro 16', 2;

/**************************************************************************
Right now procedure calls a function just to check stock, but SQL Server can handle that directly 
inside the procedure with an IF EXISTS condition.
This avoids a function call overhead and makes the flow more compact.
Refactored version without the fn_check_product function:
**************************************************************************/

CREATE OR ALTER PROCEDURE pr_product_sale (@p_product_name VARCHAR(30), @p_quantity INT)
AS 
BEGIN
    DECLARE
        @v_prod_code   VARCHAR(30),
        @v_price       INT;

    -- Check product availability directly
    IF EXISTS (
        SELECT 1
        FROM products
        WHERE product_name = @p_product_name
          AND quantity_remaining >= @p_quantity
    )
    BEGIN 
        -- Fetch product details
        SELECT @v_prod_code = product_code, 
               @v_price = price
        FROM products
        WHERE product_name = @p_product_name;

        -- Insert into sales
        INSERT INTO sales 
        VALUES (CAST(GETDATE() AS DATE), @v_prod_code, @p_quantity, @v_price * @p_quantity);

        -- Update product stock
        UPDATE products
        SET quantity_remaining = quantity_remaining - @p_quantity,
            quantity_sold = quantity_sold + @p_quantity
        WHERE product_code = @v_prod_code;

        PRINT('Product sold successfully!');
    END;
    ELSE 
        PRINT('Failure: Out of Stock!');
END;

-- Test it
EXEC pr_product_sale 'MacBook Pro 16', 2;
