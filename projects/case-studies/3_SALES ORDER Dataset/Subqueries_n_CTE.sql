
-- Subqueries & CTE 


-- Using the Sales Order Dataset:
select * from sales_order;
select * from customers;
select * from products;



1) Find the most profitable orders. Most profitable orders are those
whose sale price exceeded the average sale price for each city 
and whose deal size was not small.

select c.city,so.*
from sales_order so
join customers c on c.customer_id = so.customer
join (select c.city, round(avg(so.sales)::decimal,2) as avg_sale_per_city
     from sales_order so
     join customers c on c.customer_id = so.customer
     group by c.city) sp_city on sp_city.city = c.city
where so.sales > sp_city.avg_sale_per_city
and deal_size <> 'Small';


with cte as 
    (select c.city, round(avg(so.sales)::decimal,2) as avg_sale_per_city
     from sales_order so
     join customers c on c.customer_id = so.customer
     group by c.city)
select c.city,so.*
from sales_order so
join customers c on c.customer_id = so.customer
join cte sp_city on sp_city.city = c.city
where so.sales > sp_city.avg_sale_per_city
and deal_size <> 'Small';



2) Find the difference in average sales for each month of 2003 and 2004.

select * from sales_order;
select * from customers;
select * from products;

-- Solution 1
with cte_2003 as
        (select extract(year from order_date) yr, extract(MON from order_date) mon
        , round(avg(sales)::decimal,2) as sale_per_month
        from sales_order
        where extract(year from order_date) = 2003
        group by extract(year from order_date), extract(MON from order_date)),
    cte_2004 as 
        (select extract(year from order_date) yr, extract(MON from order_date) mon
        , round(avg(sales)::decimal,2) as sale_per_month
        from sales_order
        where extract(year from order_date) = 2004
        group by extract(year from order_date), extract(MON from order_date))
select y3.mon, abs(y3.sale_per_month - y4.sale_per_month) as monthly_diff
from cte_2003 y3
join cte_2004 y4 on y3.mon = y4.mon;


-- Solution 2
with cte as
        (select extract(year from order_date) yr, extract(MON from order_date) mon
        , round(avg(sales)::decimal,2) as sale_per_month
        from sales_order
        where extract(year from order_date) in (2003, 2004)
        group by extract(year from order_date), extract(MON from order_date))
select y3.mon , abs(y3.sale_per_month - y4.sale_per_month) as monthly_diff 
from cte y3
join cte y4 on y3.mon = y4.mon
where y3.yr = 2003 
and y4.yr = 2004;
