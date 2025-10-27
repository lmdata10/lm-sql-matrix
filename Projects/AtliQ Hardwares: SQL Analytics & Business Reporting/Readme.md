# AtliQ Hardwares Industry Data Analytics

[![SQL](https://img.shields.io/badge/SQL-MySQL-blue.svg)](https://www.mysql.com/) [![License](https://img.shields.io/badge/License-MIT-green.svg)](https://claude.ai/chat/LICENSE) [![Status](https://img.shields.io/badge/Status-Complete-success.svg)](https://claude.ai/chat/edb1dbeb-9bd9-4387-9707-7e4eace1bde2)

A comprehensive SQL analytics project exploring finance, customer performance, and supply chain optimization in the hardware industry.

## Overview

This is an end-to-end data analytics project that demonstrates advanced SQL capabilities by extracting actionable insights from hardware industry data. The project analyzes over 1.5 million records across multiple fact and dimension tables, uncovering trends in financial performance, customer behavior, and supply chain efficiency.

**Project Goals:**

- Analyze financial metrics (P&L, gross sales, net sales)
- Identify top-performing markets, customers, and products
- Evaluate supply chain forecast accuracy
- Optimize query performance for large datasets

## 💼 Business Problem

AtliQ Hardware needs to:

1. **Track financial performance** across markets and product lines
2. **Identify revenue drivers** among customers and products
3. **Improve forecast accuracy** to optimize inventory and reduce costs
4. **Make data-driven decisions** for strategic planning

## ✨ Key Features

### Finance Analysis

- Monthly and yearly revenue tracking
- P&L statement generation
- Gross price and net sales calculations
- Customer-level profitability analysis

### Top Performers Analysis

- Top N markets by net sales
- Customer segmentation by revenue contribution
- Product performance by division
- Regional market analysis

### Supply Chain Analysis

- Forecast accuracy measurement
- Year-over-year accuracy comparison
- Absolute and net error analysis
- Automated data synchronization with triggers

### Performance Optimization

- Query execution time reduced by 50%
- Efficient use of generated columns
- Strategic indexing and view creation

## 🛠️ Technical Stack

- **Database**: MySQL 8.0+
- **IDE**: Visual Studio Code
- **Version Control**: Git & GitHub
- **Languages**: SQL

## 🔍 Key Analyses

### 1. Finance Analysis

**Objectives:**

- Generate monthly product sales reports
- Track gross sales aggregates
- Create yearly revenue summaries
- Assign market performance badges

**Key Queries:**

```sql
-- Monthly sales for specific customer (FY 2021)
SELECT 
    s.date,
    p.product,
    s.sold_quantity,
    ROUND(g.gross_price * s.sold_quantity, 2) AS gross_price_total
FROM fact_sales_monthly s
JOIN dim_product p ON s.product_code = p.product_code
JOIN fact_gross_price g ON g.product_code = s.product_code
WHERE s.customer_code = 90002002 
    AND get_fiscal_year(s.date) = 2021;
```

### 2. Top Performers Analysis

**Objectives:**

- Identify top markets by net sales
- Rank customers by revenue contribution
- Analyze product performance by division
- Compare regional performance

**Performance Optimization:**

- Added generated `fiscal_year` column to reduce function calls
- Created layered views for complex calculations
- Achieved 50% query execution time reduction

### 3. Supply Chain Analysis

**Objectives:**

- Measure forecast accuracy across customers
- Calculate net and absolute errors
- Compare year-over-year performance
- Automate data integration with triggers

**Key Metrics:**

- Forecast Accuracy = 100% - Absolute Error %
- Net Error = Forecast - Actual
- Absolute Error = |Forecast - Actual|

## 📊 Results & Insights

### Financial Performance

- **363% growth** from 2020 ($12.6M) to 2021 ($58M)
- Consistent year-over-year revenue increase
- Strong upward trajectory indicating market expansion

### Market Leaders

|Market|Net Sales ($M)|% of Total|
|---|---|---|
|India|445.25|35.2%|
|USA|288.90|22.8%|
|South Korea|121.83|9.6%|

### Top Customers

|Customer|Net Sales ($M)|
|---|---|
|Amazon|218.21|
|Atliq Exclusive|159.31|
|Atliq e Store|133.08|

### Top Products

|Product|Net Sales ($M)|
|---|---|
|AQ BZ Allin1 Gen 2|84.63|
|AQ HOME Allin1 Gen 2|78.84|
|AQ Smash 2|73.55|

### Supply Chain Findings

- Forecast accuracy ranges **15-47%** (requires improvement)
- Multiple customers experienced **declining accuracy** year-over-year

## 🎓 SQL Techniques Used

### Advanced Queries

- ✅ Complex JOINs (INNER, LEFT, FULL via UNION)
- ✅ Common Table Expressions (CTEs)
- ✅ Window Functions (DENSE_RANK, SUM OVER)
- ✅ Subqueries and nested queries

### Database Objects

- ✅ User-Defined Functions (fiscal year, fiscal quarter)
- ✅ Stored Procedures (reusable reports)
- ✅ Views (layered calculations)
- ✅ Triggers (automated data sync)

### Performance Optimization

- ✅ Generated columns for computed values
- ✅ Strategic indexing
- ✅ Query execution analysis with EXPLAIN ANALYZE
- ✅ Efficient aggregation techniques

### Data Management

- ✅ ETL pipeline implementation
- ✅ NULL value handling
- ✅ Data integrity constraints
- ✅ Transaction management

### Usage Examples

**Get monthly gross sales for a customer:**

```sql
CALL get_monthly_gross_sales_for_customer(90002002);
```

**Get top 5 markets by net sales:**

```sql
CALL get_top_n_markets_by_net_sales(2021, 5);
```

**Get forecast accuracy report:**

```sql
CALL get_forecast_accuracy(2021);
```

**Assign market badge:**

```sql
CALL get_market_badge('India', 2021, @badge);
SELECT @badge;
```

## 📈 Project Stats

- **Lines of SQL Code**: 1,000+
- **Database Tables**: 10+
- **Stored Procedures**: 6
- **User-Defined Functions**: 2
- **Views**: 4
- **Triggers**: 2
- **Records Analyzed**: 1.5M+

**Full Documentation:** [Detailed Project Documentation](/Projects/AtliQ%20Hardwares:%20SQL%20Analytics%20&%20Business%20Reporting/Detailed-project-walk-through.md)

## Connect with Me

Limesh Mahial
- LinkedIn: [linkedin.com/in/lmahial](https://linkedin.com/in/lmahial)
- Email: [lm.datadev.10@gmail.com](mailto:lm.datadev.10@gmail.com)

## 🙏 Acknowledgments

- **[Codebasics](https://codebasics.io/)** for the project inspiration
- **[AtliQ Technologies](https://www.atliq.com/)** for the business case study and dataset.
- MySQL [documentation](https://dev.mysql.com/doc/) and community
