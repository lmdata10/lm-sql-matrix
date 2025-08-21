**Session:** DDL, Data Types, Contraints

---

## Exploring Tables in PostgreSQL

```sql
-- List all tables in the public schema
SELECT * FROM information_schema.tables WHERE table_schema = 'public';
```

**Notes:**

- Default schema in PostgreSQL: `public`
- Default schema in other DBs:
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

### **Banking Dataset – PostgreSQL Practice**

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
    balance DECIMAL(12,2) CHECK (balance >= 0),
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

![ERD](/=images/ERD_Banking_assignment.png)

---

*Day 2 learning completed*