## **AtliQ Hardwares: SQL Analytics & Business Reporting**

### **Key Project Outcomes: $58M Growth, Market Optimization, and Forecast Strategy**

This project leverages advanced SQL to deliver **actionable business intelligence** for a hardware company across Finance, Sales, and Supply Chain domains.

| Business Metric    | Result                                                         | Impact & Action                                                                         |
| ------------------ | -------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Gross Sales Growth | **$58M** in FY 2021 (from $12.6M in 2020).                     | Identified **explosive, effective growth** to capitalize on.                            |
| Top Markets        | India ($445M) and USA ($288M) are **primary revenue drivers**. | Confirmed focus areas for **strategic growth and resource allocation**.                 |
| Forecast Accuracy  | Low accuracy (15-47%) across major markets.                    | Flagged immediate need to **refine forecasting models** and stabilize the supply chain. |
| Process Efficiency | Automated 5+ key reports using **Stored Procedures**.          | Reduced manual work and enabled **instant, repeatable analysis** for stakeholders.      |


---

### ⚙️ **Technical Mastery & Data Engineering**

This project was a hands-on exercise in optimizing performance and building scalable data solutions.

- **Advanced SQL & Optimization:** Mastered **CTEs, Window Functions (`DENSE_RANK()`, `SUM() OVER()`), Joins, and Views** to model complex business logic. Used `EXPLAIN ANALYZE` to troubleshoot and implement performance enhancements (e.g., adding a generated `fiscal_year` column to a fact table).

- **Database Objects:** Implemented **Stored Procedures** (5+) to streamline reporting for Top Markets, Customers, and Forecast Accuracy.

- **Data Pipeline:** Created a new `fact_act_estimate` table using a **FULL JOIN simulation (`LEFT JOIN` + `UNION`)** to handle NULLs in sales and forecast data. Implemented **Database Triggers** to ensure this new table is automatically updated with new sales and forecast entries, demonstrating basic ETL/data warehousing skills.

- **Tools:** **MySQL, MySQL Workbench, Visual Studio Code, Version Control (Git/GitHub)**.

---

### 📊 **Core Analysis Highlights**

#### **1. Financial Health (Finance Analysis)**

- Developed a P&L-focused analysis to report key metrics: Gross Price, Net Sales, COGS, and Gross Margin.
- Implemented **User-Defined Functions (UDFs)** for `get_fiscal_year` and `get_fiscal_quarter` to correctly align analysis with the company's financial calendar.
- **Automation:** Developed a stored procedure (`get_monthly_gross_sales_for_customer`) to quickly generate monthly gross sales reports for _any_ customer.

#### **2. Top Performers (Sales & Market Analysis)**

- Created a dimensional model by developing **three crucial database views** to calculate Net Sales: `sales_preinvoice_discount`, `sales_postinvoice_discount`, and the final `net_sales` view.
- Identified **Top 5 Markets, Customers (Amazon, Atliq Exclusive)**, and **Products (AQ BZ Allin1 Gen 2)** by Net Sales for FY 2022.
- Designed a multi-level report to retrieve the **Top 2 Markets within each geographical Region** (APAC, EU, NA, LATAM) based on gross sales.

#### **3. Supply Chain & Forecasting (SCM Analysis)**

- Calculated **Forecast Accuracy** (`100% - Absolute Error %`) for all customers.
- Identified customers with the **most significant decline** in forecast accuracy from **FY 2020 to FY 2021**, pinpointing specific areas (e.g., South Korea) with poor performance (e.g., 15-17% accuracy).
- Created a stored procedure (`get_forecast_accuracy`) for immediate, recurring monitoring of supply chain health.

---

### **What I Learned (Execution Over Preparation)**

This project forced me to shift from theoretical planning to **hands-on execution**. The most critical learning came from **solving real-world data problems:**

1. **Modeling Complexity:** Structuring multiple layers of deductions (pre- and post-invoice) into a coherent, calculated **Net Sales metric** via database views.
2. **Performance Tuning:** The hard lesson that a simple UDF call on a filter can be a massive bottleneck, leading to the **implementation of a generated column** for a 50% speed improvement.
3. **Data Quality:** Strategically using `LEFT JOIN` + `UNION` to simulate a `FULL JOIN` and define a consistent process for handling **NULL values (missing sales/forecast data)** in a new core reporting table.

---
### **Next Steps**

I’m currently focused on **translating these SQL insights into a BI dashboard** (Power BI/Tableau) to complete the data storytelling process.