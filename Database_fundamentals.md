# Session 01: Introduction, Databases, RDBMS, Keys, Cardinality, Command Types

## Introduction to SQL

### What is Data?
- Raw facts and figures with no inherent meaning
- Examples: numbers, text, dates, images
- Becomes meaningful information when processed and organized

### What is a Database?
- An organized collection of structured data
- Stored electronically within a computer system
- Enables efficient storage, retrieval, and management of data

### How is Data Stored in a Database?
- Stored in **tables** (rows and columns)
- **Rows** = records/entities
- **Columns** = attributes/fields
- Related tables are linked using **relationships**

### What Database Are We Using?
- **Relational Database Management System (RDBMS)**
- Structured tables with predefined relationships
- Examples: PostgreSQL, MySQL, SQL Server, Oracle

### What is SQL?
- **Structured Query Language**
- Standard language for managing relational databases
- Used to **Create**, **Read**, **Update**, and **Delete** data (CRUD)

### Why SQL?
- Universal, standard language for databases
- Easy to learn and widely adopted
- Extremely powerful for data manipulation and analytics

### What is a Schema?
- Logical structure that organizes the database
- Contains tables, views, indexes, and relationships
- Acts as the blueprint for database design

### Installing PostgreSQL
- **Mac**: Use Homebrew or download from [postgresql.org](https://www.postgresql.org)
- **Windows**: Use graphical installer from [postgresql.org](https://www.postgresql.org)
- Follow the wizard and set a password for the default postgres user

### Installing PgAdmin
- Download from [pgadmin.org](https://www.pgadmin.org) for all OS
- GUI-based web interface for PostgreSQL
- Supports database visualization, query execution, and user management

### Practice

```sql
-- Create new database
CREATE DATABASE test_db;

-- Create new schema
CREATE SCHEMA test_schema;
```

## What Are Databases?

> [!Note]
> "A software that organizes and stores your data correctly, allowing you to retrieve it in the format you need, whenever you need it."

### Key Uses of Databases
1. **Data Storage**: Retains large volumes of data for easy access
2. **Data Analysis**: Derive business insights and performance metrics
3. **Record Keeping**: Maintain logs of transactions, users, inventories
4. **Foundation for Web/Mobile Apps**: Enables dynamic content, user authentication, etc.

### CRUD Operations
- **Create** – Add new records (e.g., register a user)
- **Retrieve** – Read or query data (e.g., login verification)
- **Update** – Modify existing records (e.g., change password)
- **Delete** – Remove data (e.g., delete account)

### Properties of an Ideal Database
1. **Integrity** – Accuracy and consistency
2. **Availability** – 24/7 uptime
3. **Security** – Protect data from unauthorized access
4. **Independence** – Supports multiple interfaces (web, mobile)
5. **Concurrency** – Handles many users simultaneously

## Types of Databases

### 1. Relational Databases (SQL)
- Tabular format with rows and columns
- Uses SQL; most widely adopted
- **Examples:** PostgreSQL, MySQL, SQL Server

### 2. NoSQL Databases
- Handles unstructured/semi-structured data (JSON, XML)
- **Example:** MongoDB

### 3. Columnar Databases (Data Warehouses)
- Stores data in columns
- Optimized for analytics (OLAP)
- **Examples:** Redshift, BigQuery

### 4. Graph Databases
- Manages networks and relationships
- **Examples:** Neo4j, Amazon Neptune

### 5. Key-Value Databases
- Simple, ultra-fast data retrieval
- **Example:** Redis

> 💡 **No one-size-fits-all** – Choose based on use case.

## Relational Database Concepts

### Key Terms
- **Relation** = Table
- **Attribute** = Column
- **Tuple** = Row
- **Cardinality** = No. of rows
- **Degree** = No. of columns
- **Null** = Missing value
- **Domain** = Allowed values for an attribute

### What is DBMS?
- Software that manages the database
- Facilitates user interaction, ensures integrity/security, handles storage

**DBMS Responsibilities:**
- CRUD operations
- Data validation and constraints
- Transaction management (ACID)
- Backup and recovery
- User and access management

## Keys in Databases

| Key | Meaning |
|-----|---------|
| **Super Key** | Any combination of columns that uniquely identifies a row |
| **Candidate Key** | A minimal Super Key; no redundant attributes |
| **Primary Key** | Chosen Candidate Key. Must be unique and NOT NULL |
| **Alternate Key** | Candidate key not chosen as Primary |
| **Composite Key** | Primary key formed by multiple columns |
| **Surrogate Key** | Artificial column (e.g., ID) used when natural keys are unsuitable |
| **Foreign Key** | Primary Key of another table used to define relationships |

## 📊 Cardinality of Relationships

### 1. One-to-One (1:1)
- One record in A relates to one in B
- **Example:** Person ↔️ Driving License

### 2. One-to-Many (1:N)
- One record in A relates to many in B
- **Example:** Branch ↔️ Students

### 3. Many-to-Many (M:N)
- Many records in A relate to many in B
- **Example:** Students ↔️ Courses

> Uses a **junction table** to handle M:N relationships.

## SQL Command Types

SQL commands are divided into five categories:

### 1. DQL (Data Query Language)
Mainly SELECT for retrieving data.

```sql
SELECT column_name FROM table_name WHERE condition;
```

### 2. DML (Data Manipulation Language)
Includes INSERT, UPDATE, DELETE for data manipulation.

```sql
INSERT INTO table_name VALUES (...);
UPDATE table_name SET column = value WHERE condition;
DELETE FROM table_name WHERE condition;
```

### 3. DDL (Data Definition Language)
Includes CREATE, ALTER, DROP, TRUNCATE for defining database structures.

```sql
CREATE TABLE table_name (...);
ALTER TABLE table_name ADD column_name datatype;
DROP TABLE table_name;
```

### 4. DCL (Data Control Language)
Includes GRANT, REVOKE for managing access and permissions.

```sql
GRANT SELECT ON table_name TO user;
REVOKE INSERT ON table_name FROM user;
```

### 5. TCL (Transaction Control Language)
Includes COMMIT, ROLLBACK, SAVEPOINT, SET TRANSACTION for transaction management.

```sql
COMMIT;
ROLLBACK TO savepoint_name;
```
![SQL Commands](/resources/images/commands.png)

### Role-Based Usage

- **Analysts, Data Scientists, Data Engineers**: Primarily use **DQL** (SELECT) for querying and analyzing data, and **DML** (INSERT, UPDATE, DELETE) for manipulating data in ETL pipelines or workflows
- **Database Administrators (DBAs)**: Focus on **DDL** for schema management, **DCL** for security and access control, and **TCL** for transaction integrity
- Data engineers may occasionally use DDL for creating temporary tables
- DBAs may use DQL/DML for troubleshooting, but their primary focus is DDL, DCL, TCL
- Analysts and engineers prioritize data querying and manipulation (DQL, DML), while DBAs focus on structure, security, and transactions (DDL, DCL, TCL)

---

***Day 1 learning completed***