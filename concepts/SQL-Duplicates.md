### SQL Deduplication: The Essential Patterns

Removing duplicates is a core task in data work. Here are the most common and battle-tested methods, from quick-and-dirty to surgical, complete with examples using a sample `employees` table.

#### **Sample Data**

```sql
-- This table has duplicates for 'John Smith' and 'Jane Doe'
CREATE TABLE employees (
    id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date DATE,
    salary INT
);

INSERT INTO employees VALUES
(1, 'John', 'Doe', '2020-01-15', 60000),
(2, 'Jane', 'Smith', '2019-03-22', 75000),
(3, 'John', 'Smith', '2021-08-01', 90000),
(4, 'Jane', 'Doe', '2020-05-10', 62000),
(5, 'Jane', 'Doe', '2022-02-28', 70000),
(6, 'John', 'Smith', '2021-08-01', 90000);
```

-----

#### 1\. `SELECT DISTINCT`: The Simplest Way

This is the fastest, most straightforward method. It keeps one copy of each unique row, but you have no control over which duplicate is kept.

> [!TIP]
> **When to use it:** When you don't care which duplicate survives. Perfect for quickly cleaning up a table.

**Example:**

```sql
SELECT DISTINCT * FROM employees;
```

*The two identical 'John Smith' records are collapsed into one, but the two 'Jane Doe' records remain because they differ in `hire_date` and `salary`.*

-----

#### 2\. `GROUP BY`: The Aggregation Method

Use this when you need to deduplicate while also aggregating data. You can choose which duplicate value to keep by using an aggregate function like `MIN()` or `MAX()`.

> [!TIP]
> **When to use it:** When you want to collapse duplicates based on a specific business rule (e.g., keeping the earliest record).

**Example:**
To find the earliest hire date for each employee:

```sql
SELECT
    first_name,
    last_name,
    MIN(hire_date) AS earliest_hire_date
FROM employees
GROUP BY
    first_name,
    last_name;
```

-----

#### 3\. `ROW_NUMBER()`: The Surgical Approach

This is the most precise and flexible method. It uses a window function to assign a unique rank to each row within a duplicate group, letting you decide exactly which one to keep.

> [!TIP]
> **When to use it:** When you need to control precisely which duplicate is kept. This is the go-to method for data engineering tasks.

**Example:**
To keep only the **latest record** for each unique employee:

```sql
SELECT
    id,
    first_name,
    last_name,
    hire_date,
    salary
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY first_name, last_name
            ORDER BY hire_date DESC
        ) AS rn
    FROM employees
) AS subquery
WHERE rn = 1;
```

*The `PARTITION BY` creates a separate group for each unique employee, and the `ORDER BY DESC` ranks the newest record with `rn = 1`.*

-----

#### 4\. `DELETE` with a CTE: The In-Place Method

This method removes duplicates directly from the original table. This is useful for large datasets where creating a new table is inefficient. This pattern is widely supported, including in Databricks.

> [!TIP]
> **When to use it:** When you need to clean a large table without creating a new one.

**Correct Databricks Pattern:**

```sql
WITH RankedEmployees AS (
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY first_name, last_name
            ORDER BY hire_date DESC
        ) AS rn
    FROM employees
)
DELETE FROM employees
WHERE id IN (
    SELECT id FROM RankedEmployees WHERE rn > 1
);
```

-----

#### 5\. `CREATE OR REPLACE TABLE`: The Atomic Method

This is a clean, atomic way to replace an entire table with a de-duplicated version in a single transaction. It's common in modern data platforms like Databricks and Snowflake.

> [!NOTE]
> This command drops the old table and all its metadata (constraints, comments, grants, etc.).

> [!TIP]
> **When to use it:** When you are working on a managed data lake or warehouse and want a simple, robust, and fast way to overwrite a table with a clean version.

**Example:**

```sql
CREATE OR REPLACE TABLE employees AS
SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY first_name, last_name
            ORDER BY hire_date DESC
        ) AS rn
    FROM employees
) AS subquery
WHERE rn = 1;
```

-----

### **Summary of Methods**

| Method | Control over which duplicate stays? | Best for... |
| :--- | :--- | :--- |
| **`SELECT DISTINCT`** | None | Simple, quick cleanups |
| **`GROUP BY`** | Yes, with an aggregate function | Deduplicating with a specific business rule |
| **`ROW_NUMBER()`** | Yes, with `ORDER BY` | Precise, flexible control |
| **`DELETE`** | Yes, with `ROW_NUMBER()` | In-place updates on large tables |
| **`CREATE OR REPLACE`** | Varies, but can be combined with other methods (like `ROW_NUMBER`) | Fast, atomic table replacement |