# *SQL Basics*

---

## Exploring Tables in PostgreSQL

```sql
-- List all tables in the public schema
SELECT * FROM information_schema.tables WHERE table_schema = 'public';
```

**Notes:**

- Default schema in PostgreSQL: `public`
- Default schema in other databases:
    - MSSQL → `dbo`
    - Oracle/MySQL → `sys`

---

## Creating & Dropping Tables

```sql
-- Create employees table
CREATE TABLE employees (
    id       INT,
    name     VARCHAR(20),
    dept_id  VARCHAR(10),
    salary   FLOAT  -- e.g., 2500.50
);

-- Drop table
DROP TABLE employees;

-- Rename table
ALTER TABLE employees RENAME TO employees_new;
ALTER TABLE employees_new RENAME TO employees;

-- View table data
SELECT * FROM employees;
```

---

## Modifying Tables

```sql
-- Add a new column
ALTER TABLE employees ADD COLUMN doj DATE;

-- Drop a column
ALTER TABLE employees DROP COLUMN doj;

-- Alter column type
ALTER TABLE department ALTER COLUMN id TYPE VARCHAR(10);
```

---

## Inserting Data

```sql
-- Insert with date conversion
INSERT INTO employees (id, name, dept_id, salary, doj)
VALUES (1, 'Sameer', 'D1', 3000, TO_DATE('2001-12-20','YYYY-MM-DD'));

-- Simple inserts
INSERT INTO employees VALUES (1, 'Raj', 'D1', 4000);
INSERT INTO employees VALUES (1, 'Mohan', 'D2', 5000);
INSERT INTO employees VALUES (1, 'Kumar', 'D1', 0);
```

**Notes:**

- `10` → integer
- `'10'` → string (varchar)
- `TO_DATE('YYYY-MM-DD')` → converts string to date

---

## Creating Department Table

```sql
CREATE TABLE department (
    id   INT,
    name VARCHAR(20)
);

-- Insert example
INSERT INTO department VALUES ('D001', 'HR');
```

---

## Constraints in PostgreSQL

|Constraint|Description|
|---|---|
|Primary Key|Unique + Not Null|
|Unique Key|Unique, can have NULL|
|Check|Validates values|
|Not Null|Prevents NULL|
|Foreign Key|References another table|
|Identity|Auto-incrementing column|
|Default|Default value|

---

## Creating Tables with Constraints

```sql
-- Employees table with constraints
CREATE TABLE employees (
    id       INT PRIMARY KEY,
    name     VARCHAR(20) NOT NULL,
    dept_id  VARCHAR(10) REFERENCES department(id),
    salary   FLOAT CHECK (salary > 0)
);

-- Department table with constraints
CREATE TABLE department (
    id   VARCHAR(10) PRIMARY KEY,
    name VARCHAR(20) NOT NULL
);
```

---

## Default Values & Identity

```sql
-- Add date column with default
ALTER TABLE employees ADD COLUMN doj DATE DEFAULT TO_DATE('2000-12-20','YYYY-MM-DD');

-- Identity examples
ALTER TABLE employees ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (START WITH 50);
ALTER TABLE employees ALTER COLUMN id DROP IDENTITY;

-- Insert using default identity
INSERT INTO employees VALUES (DEFAULT, 'Hanan', 'D001', 4000);
```

---

## Viewing Data

```sql
SELECT * FROM employees;
SELECT * FROM department;
```

---

## Assignment / Practice

1. Choose a dataset: Banking, Healthcare, Sales, or any domain.
2. Create a new database.
3. Create **at least 4 tables** with meaningful relationships.
4. Add **constraints** to enforce data integrity.
5. Load **at least 5 sample records** per table.

### Banking Dataset – PostgreSQL Practice

#### Create Database

```sql
CREATE DATABASE BankDB;
-- Connect to the database
\c BankDB;
```

#### Create Tables

```sql
-- Branches Table
CREATE TABLE Branches (
    branch_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    branch_address VARCHAR(200),
    branch_city VARCHAR(50)
);

-- Customers Table
CREATE TABLE Customers (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE,
    date_of_birth DATE NOT NULL
);

-- Accounts Table
CREATE TABLE Accounts (
    account_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(12,2) DEFAULT 0 CHECK (balance >= 0),
    opened_date DATE DEFAULT CURRENT_DATE,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT fk_branch FOREIGN KEY (branch_id) REFERENCES Branches(branch_id)
);

-- Transactions Table
CREATE TABLE Transactions (
    transaction_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_type VARCHAR(10) CHECK (transaction_type IN ('Deposit', 'Withdrawal')),
    amount DECIMAL(10,2) CHECK (amount > 0),
    CONSTRAINT fk_account FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);
```

#### Insert Data

```sql
-- Customers
INSERT INTO Customers (first_name, last_name, email, phone, date_of_birth) VALUES
('Alice', 'Smith', 'alice.smith@email.com', '555-1010', '1985-06-15'),
('Rohan', 'Sharma', 'rohan.sharma@email.com', '555-1020', '1990-09-20'),
('Li', 'Youn', 'li.youn@email.com', '555-1030', '1988-02-28'),
('Diana', 'Prince', 'diana.prince@email.com', '555-1040', '1992-12-01'),
('Ahmed', 'Abbas', 'ahmed.abbas@email.com', '555-1050', '1980-07-04');

-- Branches
INSERT INTO Branches (branch_name, branch_address, branch_city) VALUES
('Downtown Branch', '123 Main St', 'Toronto'),
('Uptown Branch', '456 Queen St', 'Toronto'),
('Eastside Branch', '789 King St', 'Mississauga'),
('Westside Branch', '321 Bay St', 'Mississauga'),
('Central Branch', '654 Front St', 'Toronto');

-- Accounts
INSERT INTO Accounts (customer_id, branch_id, account_type, balance) VALUES
(1, 1, 'Savings', 5000.00),
(2, 2, 'Checking', 2500.00),
(3, 3, 'Savings', 4000.00),
(4, 4, 'Checking', 1500.00),
(5, 5, 'Savings', 8000.00);

-- Transactions
INSERT INTO Transactions (account_id, transaction_type, amount) VALUES
(1, 'Deposit', 1000.00),
(1, 'Withdrawal', 500.00),
(2, 'Deposit', 2000.00),
(3, 'Withdrawal', 1000.00),
(4, 'Deposit', 500.00),
(5, 'Withdrawal', 2000.00);
```

### Notes / Practice Takeaways

- **Relationships:**
    - `accounts.customer_id → customers.customer_id`
    - `transactions.account_id → accounts.account_id`
- **Constraints used:**
    - `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `NOT NULL`, `CHECK`, `DEFAULT`
- **Data types:**
    - `INT` → integer IDs
    - `VARCHAR(20)` → string fields
    - `DECIMAL(12,2) / FLOAT` → precise decimals (balance, amount)
    - `DATE` → date values

### ERD

![ERD_Banking_assignment.png](/=images/ERD_Banking_assignment.png)

---

## `TRUNCATE` (DDL) & `DELETE` (DML)

`TRUNCATE` empties the table and removes all records permanently while keeping the table structure.

```sql
TRUNCATE TABLE employees WHERE salary < 1000;
-- This will not work

TRUNCATE TABLE employees; -- This will work
```

`DELETE` is used to delete records that match a certain filter condition, or we can delete all records directly.

```sql
DELETE FROM employees WHERE salary < 1000;
-- This will work fine, and it's the best way to DELETE with conditions

DELETE FROM employees; -- This would also work fine, BUT...
```

In our example, we had only 10-15 records, so the `DELETE FROM employees;` query is acceptable. However, in real-world scenarios, organizational data contains millions of rows, and this query would take hours to run, making it inefficient.

Instead, we can use the `TRUNCATE` command, which empties the table faster. Internally, `DELETE` works row by row, whereas `TRUNCATE` recreates the table structure. Running `TRUNCATE` doesn't depend on the number of rows and doesn't need to process each row individually.

## `UPDATE` - DML

```sql
UPDATE employees
SET salary = salary * 2
WHERE salary <= 1000;
-- The above will only update the salary of employees who have a salary less than or equal to 1000

-- Now let's say we run the same query without the filter condition
UPDATE employees
SET salary = salary * 2;

-- This would update the salary of all employees and multiply it by 2. You could end up updating all records in your database!
```

> **Note:**
> 
> - Always use a filter condition when using `UPDATE` or `DELETE` commands, or try performing a SELECT statement first to verify the records you are trying to delete or update.
> - We don't want to end up updating wrong records or all records in our database. If this is a production database containing millions of rows, you'll end up updating all records, which will cause significant problems.

```sql
-- Update with multiple fields and filters
UPDATE employees
SET salary = salary + 100, name = name || ' ***' -- || concatenates text fields
WHERE salary > 10000;
```

## `MERGE` - DML

You can merge multiple DML statements together, such as using `UPDATE` & `INSERT` together or `UPDATE` & `DELETE` together.

```sql
CREATE TABLE employees_history
AS
SELECT * FROM employees
WHERE 1 = 2;

MERGE INTO employees_history h
USING employees e ON e.id = h.id
WHEN MATCHED THEN
UPDATE SET salary = e.salary
WHEN NOT MATCHED THEN
INSERT (id, name, dept_id, salary, doj)
VALUES (e.id, e.name, e.dept_id, e.salary, e.doj);
```

## VIEWS

```sql
CREATE VIEW emp
AS
SELECT id, name, dept_id FROM employees;

SELECT * FROM emp;
```

## DCL (`GRANT` & `REVOKE`)

Let's say you have a team of auditors coming for a visit who want to examine the data, but you can't provide them access to the entire database. We can grant them access to the VIEW.

```sql
-- Create a new user called 'auditors'
GRANT SELECT ON emp TO auditors;
REVOKE SELECT ON emp FROM auditors;
```

> **View vs. New Table?**

Let's say I create a new table called `employees2` and grant them access to that. But what if my production `employees` database is being regularly updated? If I created `employees2` a few days or weeks ago, it will only contain data up to that date or time, whereas a VIEW will show updated data without giving direct access to the actual database.

## TCL

With advancements in recent tools like Snowflake and Databricks, these commands are now handled internally by the system, and we don't typically use TCL commands. However, in legacy systems, you may still need to use them.

```sql
-- TCL (first uncheck Auto Commit in the tool)
SELECT * FROM employees;

INSERT INTO employees VALUES (DEFAULT, 'David', 'D001', 44000);
INSERT INTO employees VALUES (DEFAULT, 'Maria', 'D001', 10099);
INSERT INTO employees VALUES (DEFAULT, 'Allen', 'D001', 95000);

ROLLBACK; -- removes any unsaved transactions from the database
COMMIT; -- saves any unsaved transactions to the database

-- Manually manage transactions in a database
INSERT INTO employees VALUES (DEFAULT, 'Alex', 'D001', 54000);
SAVEPOINT s1;

INSERT INTO employees VALUES (DEFAULT, 'Ken', 'D001', 99099);
SAVEPOINT s2;

INSERT INTO employees VALUES (DEFAULT, 'Hang', 'D001', 98000);
SAVEPOINT s3;

ROLLBACK TO s2;

COMMIT;
```

## DQL - `SELECT`

SELECT - Fetch (read) data from the database.

```sql
SELECT -- list of columns (which will be returned in output)
FROM -- list of tables or the table from which data will be fetched
WHERE -- filter condition (filters data based on conditions)
```

---

## Solving Queries

We will be using our Banking Dataset. You can refer to the [banking case study](/projects/case-studies/1-learn-SQL-%20Basics-using-banking-dataset/) for the dataset, insert script, and full queries.

We will solve a few questions or queries and learn basic SQL concepts like Functions, Operators, Case Statements, and UNION. The goal is to learn by doing.

### Types of Functions in SQL

- **Built-in functions** - TO_CHAR, TO_DATE, SUBSTRING, CONCAT / (||), SPLIT_PART, REPLACE, CAST

- **Aggregate functions** - SUM, AVG, COUNT, MIN, MAX

Explaining REPLACE and CAST using the below question and query:

```sql
-- 12) Display the movie name and watch time (in both minutes and hours) which have over 9 IMDB rating.

SELECT series_title,
       runtime AS runtime_mins,
       CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60 AS runtime_hrs,
       ROUND(CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60, 2) AS runtime_hrs_rounded -- for understanding the conversion and wrapping functions
FROM imdb_top_movies
WHERE imdb_rating > 9;
```

Explaining SUBSTRING, POSITION, SPLIT_PART, LEFT, and RIGHT using the example below:

```sql
-- 1) Split the value '1234_1234' into 2 separate columns having 1234 each.

-- To understand the functions better, let's first solve it the lengthy way using both SUBSTRING and POSITION
SELECT
    SUBSTRING('1234_1234', 1, POSITION('_' IN '1234_1234') - 1) AS first_part,
    SUBSTRING('1234_1234', POSITION('_' IN '1234_1234') + 1) AS second_part;

-- Another method
SELECT
    SUBSTRING('1234_1234' FROM 1 FOR 4) AS first_part,
    SUBSTRING('1234_1234' FROM 6 FOR 4) AS second_part;

-- SPLIT_PART is more flexible and dynamic
SELECT
    SPLIT_PART('1234_1234', '_', 1) AS first_part,
    SPLIT_PART('1234_1234', '_', 2) AS second_part;

-- Another method
SELECT
    LEFT('1234_1234', 4) AS first_part,
    RIGHT('1234_1234', 4) AS second_part;
```

> **Tip:** 
> Use IF EXISTS with DROP commands to avoid errors. If you try to drop a table that doesn't exist, it will throw an error and create problems during query execution.

> **Important:**
> When using aggregate functions with GROUP BY, the column you're grouping by needs to be in the SELECT statement. If that column is not included in the SELECT statement and only aggregations are used, that's fine, but you can't use other columns besides the grouped column.

```sql
-- This will work
SELECT AVG(sales) AS average_sale_price
FROM sales_orders
GROUP BY size;

-- This will work
SELECT size, AVG(sales) AS average_sale_price
FROM sales_orders
GROUP BY size;

-- This will NOT work
SELECT product, AVG(sales) AS average_sale_price
FROM sales_orders
GROUP BY size;
```

> **Difference between COUNT(\*), COUNT(1), and COUNT(column_name):**

```sql
CREATE TABLE baby_names (
    id   INT,
    name VARCHAR(20)
);

INSERT INTO baby_names VALUES(1, 'Zayn');
INSERT INTO baby_names VALUES(2, 'Xeke');
INSERT INTO baby_names VALUES(3, 'Joy');
INSERT INTO baby_names VALUES(1, 'Gohan');
INSERT INTO baby_names VALUES(4, NULL);

SELECT * FROM baby_names;

SELECT COUNT(*), COUNT(1), COUNT(name), COUNT(id)
FROM baby_names;
```

|count(*)|count(1)|count(name)|count(id)|
|---|---|---|---|
|5|5|4|5|

- `COUNT(*)` counts the number of records
- `COUNT(1)` does the same - puts 1 on each row and keeps adding it
- `COUNT(column_name)` counts all non-null rows

### Difference between WHERE and HAVING:

- **WHERE** is used to filter data returned from a table/view/result set
- **HAVING** is used to filter data returned from a GROUP BY