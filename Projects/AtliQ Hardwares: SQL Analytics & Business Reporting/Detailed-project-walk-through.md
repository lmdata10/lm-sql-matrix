# AtliQ Technologies: SQL Reporting Engine

A comprehensive SQL analytics project exploring finance, sales performance, and supply chain optimization in the hardware industry.

## Project Overview

This project demonstrates end-to-end SQL analysis capabilities by extracting actionable insights from hardware industry data. The analysis spans three core areas:

- **Finance Analysis**: Revenue trends, P&L statements, and profitability metrics
- **Sales Analysis**: Customer, product, and market segmentation
- **Supply Chain Analysis**: Forecast accuracy and demand planning optimization

The goal is to identify growth opportunities, optimize operations, and drive data-informed strategic decisions.

## Tools & Technologies

- **SQL & MySQL**: Core querying and database management
- **Visual Studio Code**: Development environment
- **Git & GitHub**: Version control and collaboration

## Supporting Concepts

### Database Fundamentals

**RDBMS (Relational Database Management System)**  
Data organized in tables with relationships, enabling efficient querying and analysis.

**ETL (Extract, Transform, Load)**  
Data pipeline process: gather from sources → transform to usable format → load into warehouse.

**Data Warehouse**  
Centralized repository for structured historical data, optimized for analysis and reporting.

**OLAP vs. OLTP**
- **OLAP**: Analytical processing for complex queries and reporting (read-heavy)
- **OLTP**: Transaction processing for real-time data entry (write-heavy)

### Data Modeling

**Fact vs. Dimension Tables**
- **Fact Tables**: Quantitative metrics (sales, revenue)
- **Dimension Tables**: Descriptive attributes (products, customers)

**Star vs. Snowflake Schema**
- **Star Schema**: Central fact table with direct dimension links (simpler, faster)
- **Snowflake Schema**: Normalized dimensions (reduced redundancy, increased complexity)

### Business Metrics

**P&L (Profit and Loss)**  
Financial statement summarizing revenues, costs, and expenses to determine profitability.

**Fiscal Year**  
12-month financial reporting period, may differ from calendar year.

**Forecast Accuracy**  
Measures how closely predictions match actual outcomes.

---

## Finance Analysis

### Business Context

Financial analysis evaluates company performance through P&L statements, examining revenues, costs, and profitability. Key metrics include gross price, net sales, COGS, and gross margin.

### Task 1: Monthly Product Sales Report

**Objective**: Generate monthly product sales for Croma India (FY 2021)

**Required Fields**: Month, Product Name, Variant, Sold Quantity, Gross Price Per Item, Gross Price Total

**Challenge**: Convert calendar year to fiscal year (starts September)

**Solution**: Created user-defined functions for reusability

```sql
-- Fiscal Year Function
CREATE FUNCTION `get_fiscal_year`(calendar_date DATE) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE fiscal_year INT;
    SET fiscal_year = YEAR(DATE_ADD(calendar_date, INTERVAL 4 MONTH));
    RETURN fiscal_year;
END;

-- Fiscal Quarter Function
CREATE FUNCTION `get_fiscal_quarter`(calendar_date DATE) 
RETURNS CHAR(2)
DETERMINISTIC
BEGIN
    DECLARE m TINYINT;
    DECLARE qtr CHAR(2);
    SET m = MONTH(calendar_date);
    CASE
        WHEN m IN (9,10,11) THEN SET qtr = 'Q1';
        WHEN m IN (12,1,2) THEN SET qtr = 'Q2';
        WHEN m IN (3,4,5) THEN SET qtr = 'Q3';
        ELSE SET qtr = 'Q4';
    END CASE;
    RETURN qtr;
END;
```

**Main Query**:

```sql
SELECT 
    s.date AS Date,
    s.product_code AS Product_Code,
    p.product AS Product_Name,
    p.variant AS Variant,
    s.sold_quantity AS Quantity,
    ROUND(g.gross_price, 2) AS Gross_Price_Per_Item,
    ROUND(g.gross_price * s.sold_quantity, 2) AS Gross_Price_Total
FROM fact_sales_monthly s
JOIN dim_product p 
    ON s.product_code = p.product_code
JOIN fact_gross_price g 
    ON g.product_code = s.product_code
    AND g.fiscal_year = get_fiscal_year(s.date)
WHERE s.customer_code = 90002002
    AND get_fiscal_year(s.date) = 2021
ORDER BY Gross_Price_Total DESC
LIMIT 25;

-- We can now export the Results in a .csv file and present the insights for Croma in FY=2021
```

### Task 2: Monthly Gross Sales Aggregate

**Objective**: Track monthly gross sales for Croma to manage customer relationships

```sql
SELECT 
    s.date,
    ROUND(SUM(s.sold_quantity * g.gross_price), 2) AS Total_Gross_Sales
FROM fact_sales_monthly s
JOIN fact_gross_price g 
    ON g.product_code = s.product_code
    AND g.fiscal_year = get_fiscal_year(s.date)
WHERE s.customer_code = 90002002
GROUP BY s.date
ORDER BY Total_Gross_Sales DESC
LIMIT 10;
```

**Results**:

|Sales Date|Total Gross Sales ($)|
|---|---|
|2021-12-01|19,537,146.56|
|2021-10-01|13,908,229.29|
|2021-09-01|11,192,823.08|
|2020-12-01|4,078,789.92|
|2020-10-01|3,109,316.88|

### Task 3: Yearly Sales Report

**Objective**: Annual gross sales summary for Croma

```sql
SELECT 
    YEAR(s.date) AS Year,
    ROUND(SUM(s.sold_quantity * g.gross_price), 2) AS Total_Gross_Sales
FROM fact_sales_monthly s
JOIN fact_gross_price g 
    ON s.product_code = g.product_code 
    AND get_fiscal_year(s.date) = g.fiscal_year
WHERE s.customer_code = 90002002
GROUP BY YEAR(s.date)
ORDER BY Year;
```

**Results**:

|Year|Total Gross Sales ($)|
|---|---|
|2017|530,768.93|
|2018|2,231,172.50|
|2019|5,506,281.69|
|2020|12,598,161.69|
|2021|58,369,684.71|

**Insights**:

- Explosive growth from 2020 to 2021 (363% increase)
- Consistent year-over-year growth trajectory
- Strong upward trend indicates successful market strategies

**Automation**: Created stored procedure for reusable reporting

```sql
CREATE PROCEDURE `get_monthly_gross_sales_for_customer`(c_code INT)
BEGIN
    SELECT 
        s.date,
        ROUND(SUM(s.sold_quantity * g.gross_price), 2) AS Total_Gross_Sales
    FROM fact_sales_monthly s
    JOIN fact_gross_price g 
        ON g.product_code = s.product_code
        AND g.fiscal_year = get_fiscal_year(s.date)
    WHERE s.customer_code = c_code
    GROUP BY s.date;
END;
```

### Task 4: Market Badge Assignment

**Objective**: Assign badges based on sales volume (Gold: >5M units, Silver: ≤5M)

```sql
CREATE PROCEDURE `get_market_badge`(
    IN in_market VARCHAR(20),
    IN in_fiscal_year YEAR,
    OUT out_badge VARCHAR(15)
)
BEGIN
    DECLARE qty INT DEFAULT 0;
    
    IF in_market = "" THEN
        SET in_market = "India";
    END IF;
    
    SELECT SUM(sold_quantity) INTO qty
    FROM fact_sales_monthly s
    JOIN dim_customer c ON s.customer_code = c.customer_code
    WHERE get_fiscal_year(s.date) = in_fiscal_year
        AND c.market = in_market
    GROUP BY c.market;
    
    IF qty > 5000000 THEN
        SET out_badge = "Gold";
    ELSE
        SET out_badge = "Silver";
    END IF;
END;
```

### Benefits of Stored Procedures

1. **Performance**: Precompiled execution for faster processing
2. **Efficiency**: Reduced network traffic
3. **Security**: Controlled data access
4. **Reusability**: Single definition, multiple uses
5. **Encapsulation**: Centralized business logic

---

## Sales Analysis

### Task 1: Net Sales Performance Report

**Objective**: Identify top markets, products, and customers by net sales for strategic planning

**Challenge**: Initial query performance issues when calculating pre-invoice discounts

#### Performance Optimization Journey

**Problem**: Query took excessive time loading 1,000 records due to fiscal year function calls on 1.5M+ rows

**Analysis Tool**: Used `EXPLAIN ANALYZE` to identify bottleneck

**Solution Approach 1**: Created `dim_date` table with generated `fiscal_year` column

**Solution Approach 2** (Implemented): Added generated `fiscal_year` column directly to `fact_sales_monthly`

```sql
ALTER TABLE fact_sales_monthly 
ADD COLUMN fiscal_year YEAR GENERATED ALWAYS AS 
(YEAR(DATE_ADD(date, INTERVAL 4 MONTH))) STORED;
```

**Result**: Nearly 50% reduction in query execution time

#### Database Views for Layered Calculations

**Pre-Invoice Discount View**:

```sql
CREATE VIEW sales_preinvoice_discount AS
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
FROM fact_sales_monthly s
JOIN dim_customer c 
    ON c.customer_code = s.customer_code
JOIN dim_product p 
    ON s.product_code = p.product_code
JOIN fact_gross_price g 
    ON g.product_code = s.product_code
    AND g.fiscal_year = s.fiscal_year
JOIN fact_pre_invoice_deductions pid 
    ON s.customer_code = pid.customer_code
    AND s.fiscal_year = pid.fiscal_year;
```

**Post-Invoice Discount View**:

```sql
CREATE VIEW sales_postinvoice_discount AS
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
    (s.gross_price_total - s.pre_invoice_discount_pct * s.gross_price_total) AS net_invoice_sales,
    (pod.discounts_pct + pod.other_deductions_pct) AS post_invoice_discount_pct
FROM sales_preinvoice_discount s
JOIN fact_post_invoice_deductions pod
    ON s.customer_code = pod.customer_code
    AND s.product_code = pod.product_code
    AND s.date = pod.date;
```

**Net Sales View**:

```sql
CREATE VIEW net_sales AS
SELECT
    *,
    net_invoice_sales * (1 - post_invoice_discount_pct) AS net_sales
FROM sales_postinvoice_discount;
```

**Gross Sales View** (Bonus):

```sql
CREATE VIEW gross_sales AS
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
FROM sales_preinvoice_discount s
JOIN dim_customer c 
    ON c.customer_code = s.customer_code;
```

#### Top Markets Analysis

```sql
SELECT
    market,
    ROUND(SUM(net_sales)/1000000, 2) AS Net_Sales_in_Millions
FROM net_sales
WHERE fiscal_year = 2022
GROUP BY market
ORDER BY Net_Sales_in_Millions DESC
LIMIT 5;
```

**Results (FY 2022)**:

|Market|Net Sales ($M)|
|---|---|
|India|445.25|
|USA|288.90|
|South Korea|121.83|
|Canada|103.20|
|United Kingdom|73.52|

**Insights**:
- India dominates with $445M (35% above USA)
- USA and South Korea show strong performance
- UK underperforms relative to market potential
- Focus on strengthening APAC and addressing EU challenges

#### Top Customers Analysis

```sql
SELECT
    c.customer,
    ROUND(SUM(net_sales)/1000000, 2) AS Net_Sales_in_Millions
FROM net_sales s
JOIN dim_customer c ON c.customer_code = s.customer_code
WHERE fiscal_year = 2022
GROUP BY c.customer
ORDER BY Net_Sales_in_Millions DESC
LIMIT 5;
```

**Results (FY 2022)**:

|Customer|Net Sales ($M)|
|---|---|
|Amazon|218.21|
|Atliq Exclusive|159.31|
|Atliq e Store|133.08|
|Flipkart|57.24|
|Sage|52.49|

**Insights**:
- Amazon leads as primary revenue driver ($218M)
- Atliq channels (Exclusive + e Store) contribute $292M combined
- Significant gap between top 3 and remaining customers
- Opportunity to grow Flipkart and Sage relationships

#### Top Products Analysis

```sql
SELECT 
    product,
    ROUND(SUM(net_sales)/1000000, 2) AS Net_Sales_in_Millions
FROM net_sales
WHERE fiscal_year = 2022
GROUP BY product
ORDER BY Net_Sales_in_Millions DESC
LIMIT 5;
```

**Results (FY 2022)**:

|Product|Net Sales ($M)|
|---|---|
|AQ BZ Allin1 Gen 2|84.63|
|AQ HOME Allin1 Gen 2|78.84|
|AQ Smash 2|73.55|
|AQ Smash 1|67.98|
|AQ Electron 3 3600 Desktop Processor|65.65|

**Insights**:
- All-in-one products dominate sales (Gen 2 variants leading)
- Smash series shows strong market acceptance
- Desktop processors maintain steady demand
- Product portfolio is well-balanced across categories

#### Automation with Stored Procedures

**Top N Markets**:

```sql
CREATE PROCEDURE `get_top_n_markets_by_net_sales`(
    in_fiscal_year INT,
    in_top_n INT  
)
BEGIN
    SELECT
        market,
        ROUND(SUM(net_sales)/1000000, 2) AS Net_Sales_in_Millions
    FROM net_sales
    WHERE fiscal_year = in_fiscal_year
    GROUP BY market
    ORDER BY Net_Sales_in_Millions DESC
    LIMIT in_top_n;
END;
```

**Top N Customers by Market**:

```sql
CREATE PROCEDURE `get_top_n_customers_by_net_sales`(
    in_market VARCHAR(45),
    in_fiscal_year INT,
    in_top_n INT  
)
BEGIN
    SELECT
        c.customer,
        ROUND(SUM(net_sales)/1000000, 2) AS Net_Sales_in_Millions
    FROM net_sales s
    JOIN dim_customer c 
        ON c.customer_code = s.customer_code
    WHERE fiscal_year = in_fiscal_year
        AND s.market = in_market
    GROUP BY c.customer
    ORDER BY Net_Sales_in_Millions DESC
    LIMIT in_top_n;
END;
```

**Top N Products by Market**:

```sql
CREATE PROCEDURE `get_top_n_products_by_net_sales`(
    in_market VARCHAR(45),
    in_fiscal_year INT,
    in_top_n INT  
)
BEGIN
    SELECT
        product,
        ROUND(SUM(net_sales)/1000000, 2) AS Net_Sales_in_Millions
    FROM net_sales s
    WHERE fiscal_year = in_fiscal_year
        AND s.market = in_market
    GROUP BY product
    ORDER BY Net_Sales_in_Millions DESC
    LIMIT in_top_n;
END;
```

### Task 2: Customer Performance by Net Sales Percentage

**Objective**: Top 10 customers by percentage contribution (FY 2021)

```sql
WITH cte1 AS (
    SELECT
        c.customer,
        ROUND(SUM(net_sales)/1000000, 2) AS Net_Sales_in_Millions
    FROM net_sales s
    JOIN dim_customer c ON c.customer_code = s.customer_code
    WHERE fiscal_year = 2021
    GROUP BY c.customer
)
SELECT 
    *,
    Net_Sales_in_Millions * 100 / SUM(Net_Sales_in_Millions) OVER() AS NS_pct
FROM cte1
ORDER BY Net_Sales_in_Millions DESC
LIMIT 10;
```

| Customer         | Net_Sales_in_Millions | NS_pct   |
| ---------------- | --------------------- | -------- |
| Amazon           | 109.03                | 13.23340 |
| Atliq Exclusive  | 79.92                 | 9.70021  |
| Atliq e Store    | 70.31                 | 8.53380  |
| Sage             | 27.07                 | 3.28559  |
| Flipkart         | 25.25                 | 3.06469  |
| Leader           | 24.52                 | 2.97609  |
| Neptune          | 21.01                 | 2.55007  |
| Ebay             | 19.88                 | 2.41291  |
| Electricalsocity | 16.25                 | 1.97233  |
| Synthetic        | 16.1                  | 1.95412  |
### Task 3: Regional Customer Performance

**Objective**: Analyze net sales distribution by customers across regions (APAC, EU, NA)

```sql
WITH cte1 AS (
    SELECT
        c.customer,
        c.region,
        ROUND(SUM(net_sales)/1000000, 2) AS Net_Sales_in_Millions
    FROM net_sales ns
    JOIN dim_customer c 
        ON c.customer_code = ns.customer_code
    WHERE fiscal_year = 2021
    GROUP BY c.customer, c.region
)
SELECT 
    *,
    Net_Sales_in_Millions * 100 / SUM(Net_Sales_in_Millions) OVER(PARTITION BY region) AS NS_pct
FROM cte1
ORDER BY region, Net_Sales_in_Millions DESC;
```

![Net-sales-distribution-apac-eu-na.png](/Projects/AtliQ%20Hardwares:%20SQL%20Analytics%20&%20Business%20Reporting/Scripts/Net-sales-distribution-apac-eu-na.png)

### Task 4: Top Products by Quantity per Division

**Objective**: Identify top 3 products by quantity sold in each division (FY 2021)

```sql
WITH cte1 AS (
    SELECT
        p.division,
        p.product,
        SUM(s.sold_quantity) AS total_qty
    FROM fact_sales_monthly s
    JOIN dim_product p
        ON p.product_code = s.product_code
    WHERE s.fiscal_year = 2021
    GROUP BY p.division, p.product
),
cte2 AS (
    SELECT
        *,
        DENSE_RANK() OVER (PARTITION BY division ORDER BY total_qty DESC) AS drnk
    FROM cte1
)
SELECT * 
FROM cte2 
WHERE drnk <= 3;
```

**Results**:

|Division|Product|Total Quantity|Rank|
|---|---|---|---|
|N&S|AQ Pen Drive DRC|2,034,569|1|
|N&S|AQ Digit SSD|1,240,149|2|
|N&S|AQ Clx1|1,238,683|3|
|P&A|AQ Gamers Ms|2,477,098|1|
|P&A|AQ Maxima Ms|2,461,991|2|
|P&A|AQ Master wireless x|2,448,784|3|
|PC|AQ Digit|135,092|1|
|PC|AQ Gen Y|135,031|2|
|PC|AQ Elite|134,431|3|

**Insights**:

- P&A division leads in volume (2.4M+ units per top product)
- N&S division shows strong performance with storage products
- PC division significantly lower volume (135K units)
- Consider marketing strategies to boost PC division sales

**Stored Procedure**:

```sql
CREATE PROCEDURE `get_top_n_products_per_division_by_qty_sold`(
    in_fiscal_year INT,
    in_top_n INT
)
BEGIN
    WITH cte1 AS (
        SELECT
            p.division,
            p.product,
            SUM(s.sold_quantity) AS total_qty
        FROM fact_sales_monthly s
        JOIN dim_product p
            ON p.product_code = s.product_code
        WHERE s.fiscal_year = in_fiscal_year
        GROUP BY p.division, p.product
    ),
    cte2 AS (
        SELECT
            *,
            DENSE_RANK() OVER (PARTITION BY division ORDER BY total_qty DESC) AS drnk
        FROM cte1
    )
    SELECT * 
    FROM cte2 
    WHERE drnk <= in_top_n;
END;
```

### Task 5: Top Markets per Region by Gross Sales

**Objective**: Retrieve top 2 markets in each region by gross sales (FY 2021)

```sql
WITH cte1 AS (
    SELECT
        c.market,
        c.region,
        ROUND(SUM(s.sold_quantity * g.gross_price)/1000000, 2) AS gross_sales_mln
    FROM fact_sales_monthly s
    JOIN fact_gross_price g
        ON s.product_code = g.product_code
        AND s.fiscal_year = g.fiscal_year
    JOIN dim_customer c 
        ON c.customer_code = s.customer_code
    WHERE s.fiscal_year = 2021
    GROUP BY c.market, c.region
),
cte2 AS (
    SELECT
        *,
        DENSE_RANK() OVER (PARTITION BY region ORDER BY gross_sales_mln DESC) AS drnk
    FROM cte1
)
SELECT * 
FROM cte2 
WHERE drnk <= 2;
```

**Results**:

|Market|Region|Gross Sales ($M)|Rank|
|---|---|---|---|
|India|APAC|455.05|1|
|South Korea|APAC|131.86|2|
|United Kingdom|EU|78.11|1|
|France|EU|67.62|2|
|Mexico|LATAM|2.30|1|
|Brazil|LATAM|2.14|2|
|USA|NA|264.46|1|
|Canada|NA|89.78|2|

**Insights**:

- India dominates APAC with 3.5x South Korea's sales
- LATAM shows minimal market penetration (growth opportunity)
- NA region demonstrates strong performance led by USA
- EU markets show balanced but moderate performance

---
## Supply Chain Analysis

### Domain Knowledge Fundamentals

Understanding supply chain metrics is crucial for accurate demand planning and inventory optimization:

1. **Forecasts**: Predicted future demand based on historical trends and market analysis
2. **Actuals**: Real-world demand or sales observed over a period
3. **Net Error**: Difference between forecast and actual values `(Forecast - Actual)`
4. **Net Error %**: Net Error as percentage of actual demand `(Net Error / Actual) × 100`
5. **Absolute Error**: Absolute difference between forecast and actual `|Forecast - Actual|`
6. **Absolute Error %**: Absolute Error as percentage of actual `(Absolute Error / Actual) × 100`
7. **Forecast Accuracy**: Proximity of forecasts to actuals `100% - Absolute Error%`

### Task 1: Aggregate Forecast Accuracy Report

**Objective**: Monitor forecast accuracy for all customers across a fiscal year

**Required Fields**: Customer Code, Name, Market, Total Sold Quantity, Total Forecast Quantity, Net Error, Absolute Error, Forecast Accuracy (%)

#### Data Integration Challenge

**Problem**: Data exists in two separate tables with potential mismatches and NULL values

- `sold_quantity` in `fact_sales_monthly`
- `forecast_quantity` in `fact_forecast_monthly`

**Solution**: FULL JOIN using UNION to combine datasets, treating NULLs as 0

#### Creating the Unified Table

```sql
-- Create fact_act_estimate table
CREATE TABLE fact_act_estimate (
    SELECT
        s.date AS date,
        s.fiscal_year AS fiscal_year,
        s.customer_code AS customer_code,
        s.product_code AS product_code,
        s.sold_quantity AS sold_quantity,
        f.forecast_quantity AS forecast_quantity
    FROM fact_sales_monthly s
    LEFT JOIN fact_forecast_monthly f 
        USING (date, customer_code, product_code)
    
    UNION
    
    SELECT
        f.date AS date,
        f.fiscal_year AS fiscal_year,
        f.customer_code AS customer_code,
        f.product_code AS product_code,
        s.sold_quantity AS sold_quantity,
        f.forecast_quantity AS forecast_quantity
    FROM fact_forecast_monthly f
    LEFT JOIN fact_sales_monthly s
        USING (date, customer_code, product_code)
);

-- Handle NULL values
UPDATE fact_act_estimate
SET sold_quantity = 0
WHERE sold_quantity IS NULL;

UPDATE fact_act_estimate
SET forecast_quantity = 0
WHERE forecast_quantity IS NULL;
```

#### Database Triggers for Automation

**Trigger for Sales Updates**:

```sql
CREATE TRIGGER `fact_sales_monthly_AFTER_INSERT` 
AFTER INSERT ON `fact_sales_monthly` 
FOR EACH ROW 
BEGIN
    INSERT INTO fact_act_estimate
        (date, product_code, customer_code, sold_quantity)
    VALUES (
        NEW.date,
        NEW.product_code,
        NEW.customer_code,
        NEW.sold_quantity
    ) 
    ON DUPLICATE KEY UPDATE 
        sold_quantity = VALUES(sold_quantity);
END;
```

**Trigger for Forecast Updates**:

```sql
CREATE TRIGGER `fact_forecast_monthly_AFTER_INSERT` 
AFTER INSERT ON `fact_forecast_monthly` 
FOR EACH ROW
BEGIN
    INSERT INTO fact_act_estimate
        (date, product_code, customer_code, forecast_quantity)
    VALUES (
        NEW.date,
        NEW.product_code,
        NEW.customer_code,
        NEW.forecast_quantity
    ) 
    ON DUPLICATE KEY UPDATE 
        forecast_quantity = VALUES(forecast_quantity);
END;
```

#### Forecast Accuracy Analysis Query

```sql
WITH forecast_calc AS (
    SELECT
        e.customer_code,
        c.customer AS Customer,
        c.market AS Market,
        SUM(sold_quantity) AS Total_Sold_Quantity,
        SUM(forecast_quantity) AS Total_Forecast_Quantity,
        SUM(forecast_quantity - sold_quantity) AS Net_Error,
        ROUND(SUM(forecast_quantity - sold_quantity) * 100 / SUM(forecast_quantity), 2) AS Net_Error_pct,
        SUM(ABS(forecast_quantity - sold_quantity)) AS Abs_Error,
        ROUND(SUM(ABS(forecast_quantity - sold_quantity)) * 100 / SUM(forecast_quantity), 2) AS Abs_Error_pct
    FROM fact_act_estimate e
    JOIN dim_customer c
        ON c.customer_code = e.customer_code
    WHERE fiscal_year = 2021
    GROUP BY customer_code
)
SELECT 
    *,
    IF(Abs_Error_pct > 100, 0, ROUND(100 - Abs_Error_pct, 2)) AS Forecast_Accuracy
FROM forecast_calc
ORDER BY Forecast_Accuracy DESC
LIMIT 5;
```

#### Results Analysis

**Top 5 Customers - Highest Forecast Accuracy (FY 2021)**:

|Customer Code|Customer|Market|Total Sold Qty|Total Forecast Qty|Net Error|Net Error %|Abs Error|Abs Error %|Forecast Accuracy|
|---|---|---|---|---|---|---|---|---|---|
|90013120|Coolblue|Italy|109,547|133,532|23,985|17.96%|70,467|52.77%|47.23%|
|70010048|Atliq e Store|Bangladesh|119,439|142,010|22,571|15.89%|75,711|53.31%|46.69%|
|90023027|Costco|Canada|236,189|279,962|43,773|15.64%|149,303|53.33%|46.67%|
|90023026|Relief|Canada|228,988|273,492|44,504|16.27%|146,948|53.73%|46.27%|
|90017051|Forward Stores|Portugal|86,823|118,067|31,244|26.46%|63,568|53.84%|46.16%|

**Key Insights**:

- Forecast accuracy ranges 46-47%, indicating significant prediction gaps
- Larger markets (Canada) show higher absolute errors but better percentage accuracy
- Smaller markets (Portugal) face higher percentage errors (26.46%)
- All customers exceed 50% absolute error, highlighting forecasting challenges

**Bottom 5 Customers - Lowest Forecast Accuracy (FY 2021)**:

|Customer Code|Customer|Market|Total Sold Qty|Total Forecast Qty|Net Error|Net Error %|Abs Error|Abs Error %|Forecast Accuracy|
|---|---|---|---|---|---|---|---|---|---|
|90007197|Amazon|South Korea|344,240|226,857|-117,383|-51.74%|191,047|84.21%|15.79%|
|90019202|Argos (Sainsbury's)|Sweden|26,581|18,218|-8,363|-45.91%|15,273|83.83%|16.17%|
|90019203|Amazon|Sweden|27,550|19,060|-8,490|-44.54%|15,928|83.57%|16.43%|
|70007198|Atliq Exclusive|South Korea|345,667|228,104|-117,563|-51.54%|188,585|82.68%|17.32%|
|70007199|Atliq e Store|South Korea|358,064|236,637|-121,427|-51.31%|194,953|82.38%|17.62%|

**Key Insights**:

- Forecast accuracy extremely low (15.79% - 17.62%)
- South Korea markets consistently under-forecasted (>51% negative error)
- Absolute errors exceed 80%, indicating severe forecasting issues
- Negative net errors suggest systematic under-prediction of demand

#### Stored Procedure for Reusability

```sql
CREATE PROCEDURE `get_forecast_accuracy`(
    in_fiscal_year INT
)
BEGIN
    WITH forecast_calc AS (
        SELECT
            e.customer_code,
            c.customer AS Customer,
            c.market AS Market,
            SUM(sold_quantity) AS Total_Sold_Quantity,
            SUM(forecast_quantity) AS Total_Forecast_Quantity,
            SUM(forecast_quantity - sold_quantity) AS Net_Error,
            ROUND(SUM(forecast_quantity - sold_quantity) * 100 / SUM(forecast_quantity), 2) AS Net_Error_pct,
            SUM(ABS(forecast_quantity - sold_quantity)) AS Abs_Error,
            ROUND(SUM(ABS(forecast_quantity - sold_quantity)) * 100 / SUM(forecast_quantity), 2) AS Abs_Error_pct
        FROM fact_act_estimate e
        JOIN dim_customer c
            ON c.customer_code = e.customer_code
        WHERE fiscal_year = in_fiscal_year
        GROUP BY customer_code
    )
    SELECT 
        *,
        IF(Abs_Error_pct > 100, 0, ROUND(100 - Abs_Error_pct, 2)) AS Forecast_Accuracy
    FROM forecast_calc
    ORDER BY Forecast_Accuracy DESC;
END;
```

### Task 2: Year-over-Year Forecast Accuracy Comparison

**Objective**: Forecast accuracy from FY 2020 to FY 2021

**Business Impact**: Helps supply chain managers prioritize improvements where performance degraded

```sql
-- Create temporary tables for each year
CREATE TEMPORARY TABLE fa_2021
WITH forecast_calc AS (
    SELECT
        e.customer_code,
        c.customer AS Customer,
        c.market AS Market,
        SUM(sold_quantity) AS Total_Sold_Quantity,
        SUM(forecast_quantity) AS Total_Forecast_Quantity,
        SUM(forecast_quantity - sold_quantity) AS Net_Error,
        ROUND(SUM(forecast_quantity - sold_quantity) * 100 / SUM(forecast_quantity), 2) AS Net_Error_pct,
        SUM(ABS(forecast_quantity - sold_quantity)) AS Abs_Error,
        ROUND(SUM(ABS(forecast_quantity - sold_quantity)) * 100 / SUM(forecast_quantity), 2) AS Abs_Error_pct
    FROM fact_act_estimate e
    JOIN dim_customer c
        ON c.customer_code = e.customer_code
    WHERE fiscal_year = 2021
    GROUP BY customer_code
)
SELECT 
    *,
    IF(Abs_Error_pct > 100, 0, ROUND(100 - Abs_Error_pct, 2)) AS Forecast_Accuracy
FROM forecast_calc
ORDER BY Forecast_Accuracy DESC;

CREATE TEMPORARY TABLE fa_2020
WITH forecast_calc AS (
    SELECT
        e.customer_code,
        c.customer AS Customer,
        c.market AS Market,
        SUM(sold_quantity) AS Total_Sold_Quantity,
        SUM(forecast_quantity) AS Total_Forecast_Quantity,
        SUM(forecast_quantity - sold_quantity) AS Net_Error,
        ROUND(SUM(forecast_quantity - sold_quantity) * 100 / SUM(forecast_quantity), 2) AS Net_Error_pct,
        SUM(ABS(forecast_quantity - sold_quantity)) AS Abs_Error,
        ROUND(SUM(ABS(forecast_quantity - sold_quantity)) * 100 / SUM(forecast_quantity), 2) AS Abs_Error_pct
    FROM fact_act_estimate e
    JOIN dim_customer c
        ON c.customer_code = e.customer_code
    WHERE fiscal_year = 2020
    GROUP BY customer_code
)
SELECT 
    *,
    IF(Abs_Error_pct > 100, 0, ROUND(100 - Abs_Error_pct, 2)) AS Forecast_Accuracy
FROM forecast_calc
ORDER BY Forecast_Accuracy DESC;

-- Compare accuracy decline
SELECT
    f20.customer_code,
    f20.customer AS Customer,
    f20.market AS Market,
    f20.Forecast_Accuracy AS Forecast_Accuracy_2020,
    f21.Forecast_Accuracy AS Forecast_Accuracy_2021
FROM fa_2020 f20
JOIN fa_2021 f21 
    ON f21.customer_code = f20.customer_code
WHERE f21.Forecast_Accuracy < f20.Forecast_Accuracy
ORDER BY Forecast_Accuracy_2020 DESC;
```

---
### SQL Applications Across Industries

1. **Ad-hoc Analysis**: Quick queries for business questions and decision support
2. **Report Generation**: Automated operational, financial, and strategic reports
3. **Exploratory Data Analysis**: Data preparation for insights and ML models
4. **BI Tool Integration**: Powering dashboards in Power BI, Tableau, Looker
5. **ETL & Data Migration**: Extract, transform, load, and integrate data
6. **CRUD Operations**: Create, read, update, delete for data management

---
## Key Learnings

### Technical Skills Developed

**Advanced SQL Mastery**

- Complex joins, subqueries, CTEs, and window functions
- Stored procedures and user-defined functions for automation
- Database triggers for real-time data synchronization
- Performance optimization with indexes and generated columns

**Query Optimization**

- Used `EXPLAIN ANALYZE` to identify performance bottlenecks
- Reduced query execution time by 50% through strategic optimizations
- Implemented generated columns for repeated calculations
- Designed efficient database views for layered data transformations

**Data Engineering**

- Built end-to-end ETL pipelines
- Automated data workflows with triggers
- Created reusable database objects (views, procedures, functions)
- Managed data integrity across multiple fact tables

### Business Intelligence

**Financial Analysis**

- Deep understanding of P&L statements and revenue metrics
- Calculated gross price, net sales, COGS, and margins
- Analyzed profitability trends and growth patterns

**Supply Chain Management**

- Forecast accuracy measurement and analysis
- Demand planning and inventory optimization concepts
- Root cause analysis for forecasting gaps

**Strategic Decision Support**

- Translated data into actionable business insights
- Identified top performers and growth opportunities
- Quantified market performance and customer value

### Problem-Solving Approach

**Real-World Scenarios**

- Handled missing data and NULL values systematically
- Resolved data integration challenges across disparate tables
- Balanced query performance with analytical depth
- Created scalable solutions for recurring business questions

---

## Key Insights Summary

### Financial Performance

**Explosive Growth Trajectory**

- Sales increased 363% from 2020 ($12.6M) to 2021 ($58M)
- Consistent year-over-year growth from 2017-2021
- Strong momentum indicating successful market strategies

### Market Analysis

**Geographic Distribution**

- **India**: Market leader with $445M net sales (35% above USA)
- **USA**: Strong second place at $288M
- **South Korea**: Solid APAC performer at $121M
- **LATAM**: Underdeveloped with <$5M (high growth potential)

### Customer Performance

**Revenue Concentration**

- **Amazon**: Primary revenue driver at $218M (17% of total)
- **Atliq Channels**: Combined $292M from Exclusive and e Store
- **Top 5 Customers**: Account for majority of revenue
- **Opportunity**: Grow mid-tier customers (Flipkart, Sage)

### Product Analysis

**Best Sellers**

- **AQ BZ Allin1 Gen 2**: Top performer at $84.63M
- **All-in-One Category**: Dominates with Gen 2 variants leading
- **Smash Series**: Strong market acceptance across variants
- **PC Division**: Underperforms relative to P&A and N&S

### Supply Chain Challenges

**Forecast Accuracy Issues**

- Overall accuracy ranges 15-47% (needs significant improvement)
- **South Korea**: Systematic under-forecasting (>80% absolute error)
- **Year-over-Year Decline**: Many customers saw accuracy drop 2020→2021
- **Critical Need**: Enhanced forecasting models and methodologies

---

## Conclusion

This project demonstrates comprehensive SQL analytics capabilities from database design through strategic insights delivery. By combining technical expertise with business acumen, I transformed raw data into actionable intelligence across finance, sales, and supply chain domains.

**Technical Achievements**:

- Optimized query performance by 50% through strategic database design
- Automated reporting workflows with stored procedures and triggers
- Built scalable data architecture using views and generated columns
- Implemented end-to-end data integration for forecast analysis

**Business Impact**:

- Identified $445M market opportunity in India
- Highlighted 363% revenue growth trajectory
- Uncovered critical forecast accuracy gaps requiring attention
- Provided data-driven recommendations for strategic planning

**Professional Growth**: This project reinforced that SQL is more than a query language—it's a powerful tool for unlocking business value. From P&L analysis to supply chain optimization, every query tells a story that drives decision-making and strategic direction.

---

## Contact

**Technologies**: SQL | MySQL | MySQL Workbench | VS Code | Git | GitHub

**Connect**: [LinkedIn](https://linkedin.com/in/lmahial) | [Email](mailto:lm.datadev.10@gmail.com)

---

_Thank you for exploring this project! Feel free to reach out for collaboration or questions._
