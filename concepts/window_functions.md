
## Window Functions

This document is a beginner-friendly guide to SQL window functions, designed as a reference for understanding and using them in ANSI SQL-compliant databases like PostgreSQL, SQL Server, Databricks, and Snowflake. It includes a theoretical explanation, practical examples using a `students` table, and an all-in-one query showing all functions together. The examples use a school context (students, subjects, marks) to make concepts intuitive.

### What Are Window Functions?

Imagine you're a teacher looking at a class list of students' test scores. You want to rank students in each subject, find the top scorer, or compare each student's marks to others in their subject _without_ summarizing the data into a single row per subject (like a `GROUP BY` would do). SQL window functions let you do this by giving each row a "window" to see related rows in the same table, like looking through a classroom window to compare students.

### Key Concepts

- **Window**: A group of rows related to the current row, defined by a `PARTITION BY` clause (e.g., grouping by subject). Think of it as splitting the class into groups by subject.
- **Ordering**: Within each window, rows can be sorted (e.g., by marks) using `ORDER BY`. This is like lining up students by their test scores.
- **Frame**: A subset of the window that some functions (like `LAST_VALUE`) use, defined by clauses like `ROWS BETWEEN`. It’s like focusing on a specific part of the line-up.
- **Window Function**: A function that computes a value for each row based on its window, like ranking a student or counting classmates in their subject.

### Why Use Window Functions?

Unlike `GROUP BY`, which collapses rows into one per group (e.g., average marks per subject), window functions keep all rows and add a new column with the computed value (e.g., each student’s rank in their subject). This makes them perfect for rankings, running totals, comparisons, and more, all while keeping the original data intact.

### Anatomy of a Window Function

A window function looks like this:

```sql
FUNCTION() OVER(PARTITION BY column ORDER BY column)
```

- `FUNCTION()`: The window function (e.g., `ROW_NUMBER`, `RANK`).
- `PARTITION BY`: Groups rows into windows (optional; without it, the whole table is one window).
- `ORDER BY`: Sorts rows within each window (optional for some functions).
- `ROWS BETWEEN`: Defines the frame (optional; used for functions like `LAST_VALUE`).

### The Window Functions

This document covers ANSI SQL window functions, divided into three categories:

1. **Ranking Functions**: Assign positions or ranks (`ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`, `CUME_DIST`, `PERCENT_RANK`).
2. **Value Functions**: Access specific values in the window (`FIRST_VALUE`, `LAST_VALUE`, `NTH_VALUE`, `LEAD`, `LAG`).
3. **Aggregate Functions**: Compute aggregates over the window (`COUNT`, `MIN`, `MAX`).

Below, each function is demonstrated with a `students` table, using analogies to a classroom setting.

####  Query Time

##### INSERT Script

```SQL
-- Create database and table
CREATE DATABASE school;

-- Drop table if it exists
DROP TABLE IF EXISTS students;

-- Create students table
CREATE TABLE students (
    student_id INT,
    student_name VARCHAR(50),
    subject VARCHAR(50),
    marks INT
);

-- Insert data into students table
INSERT INTO students VALUES
(101, 'Alice', 'Math', 85),
(102, 'Bob', 'Math', 90),
(103, 'Charlie', 'Math', 85),
(104, 'David', 'Math', 95),
(105, 'Emma', 'Science', 88),
(106, 'Fiona', 'Science', 92),
(107, 'George', 'Science', 78),
(108, 'Hannah', 'Science', 92),
(109, 'Isabella', 'English', 80),
(110, 'James', 'English', 85),
(111, 'Kelly', 'English', 90),
(112, 'Liam', 'English', 75),
(113, 'Mia', 'Math', 88),
(114, 'Noah', 'Science', 85),
(115, 'Olivia', 'English', 88);
```

##### Window Function Examples

Each function is explained with an analogy and a query using the students table.
All queries use ANSI SQL for compatibility with PostgreSQL, SQL Server, Databricks, and Snowflake
###### 1. ROW_NUMBER()

- Analogy: Imagine lining up students in each subject by their student ID for a class photo. Each gets a unique number (1, 2, 3...) in that line.
- Purpose: Assigns a unique sequential number to each row within a partition (e.g., subject).

```sql
SELECT student_id, student_name, subject, marks,
       ROW_NUMBER() OVER(PARTITION BY subject ORDER BY student_id) AS row_num
FROM students;
```

###### 2. RANK()

- **Analogy:** In a test score competition for each subject, students with the same marks get the same rank, but the next rank skips numbers (e.g., 1, 1, 3).
- **Purpose:** Assigns a rank based on a column (e.g., marks), with ties getting the same rank and gaps in numbering.

```sql
SELECT student_id, student_name, subject, marks,
       RANK() OVER(PARTITION BY subject ORDER BY marks DESC) AS marks_rank
FROM students;
```

###### 3. DENSE_RANK()

- **Analogy:** Like RANK(), but no skipping numbers after ties (e.g., 1, 1, 2 instead of 1, 1, 3).
- **Purpose:** Assigns ranks without gaps in numbering for ties.

```sql
SELECT student_id, student_name, subject, marks,
       DENSE_RANK() OVER(PARTITION BY subject ORDER BY marks DESC) AS dense_marks_rank
FROM students;
```
###### 4. FIRST_VALUE()

- **Analogy:** Picture a leaderboard for each subject showing the name of the student with the highest marks at the top.
- **Purpose:** Returns the first value in a partition based on the ordering.

```sql
SELECT student_id, student_name, subject, marks,
       FIRST_VALUE(student_name) OVER(PARTITION BY subject ORDER BY marks DESC) AS top_scorer
FROM students;
```

###### 5. LAST_VALUE()

- **Analogy:** Look at the student with the lowest marks in each subject’s ordered list, like checking the last name on a ranked class list.
- **Purpose:** Returns the last value in a partition. Requires FRAME specification for correct results.

```sql
SELECT student_id, student_name, subject, marks,
       LAST_VALUE(student_name) OVER(PARTITION BY subject ORDER BY marks DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lowest_scorer
FROM students;
```

###### 6. NTH_VALUE()

- **Analogy:** Pick the student who got the 2nd highest marks in each subject, like awarding a silver medal.
- **Purpose:** Returns the Nth value in a partition based on the ordering.

```sql
SELECT student_id, student_name, subject, marks,
       NTH_VALUE(student_name, 2) OVER(PARTITION BY subject ORDER BY marks DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS second_highest_scorer
FROM students;
```

###### 7. LEAD()

- **Analogy:** Look at the student just behind you in a marks-ordered line for your subject, like checking who’s next in a race.
- **Purpose:** Accesses the next row’s value in the partition.

```sql
SELECT student_id, student_name, subject, marks,
       LEAD(student_name) OVER(PARTITION BY subject ORDER BY marks DESC) AS next_lower_scorer
FROM students;
```

###### 8. LAG()

- **Analogy:** Look at the student just ahead of you in a marks-ordered line for your subject, like checking who’s in front in a race.
- **Purpose:** Accesses the previous row’s value in the partition.

```sql
SELECT student_id, student_name, subject, marks,
       LAG(student_name) OVER(PARTITION BY subject ORDER BY marks DESC) AS previous_higher_scorer
FROM students;
```

###### 9. COUNT()

- **Analogy:** Count how many students took the same subject, like counting how many classmates are in your math class.
- **Purpose:** Counts rows in a partition.

```sql
SELECT student_id, student_name, subject, marks,
       COUNT(*) OVER(PARTITION BY subject) AS subject_student_count
FROM students;
```

###### 10. MIN()

- **Analogy:** Find the lowest marks scored in your subject, like spotting the lowest grade in a class test.
- **Purpose:** Returns the minimum value in a partition.

```sql
SELECT student_id, student_name, subject, marks,
       MIN(marks) OVER(PARTITION BY subject) AS min_marks_in_subject
FROM students;
```

###### 11. MAX()

- **Analogy:** Find the highest marks scored in your subject, like spotting the top grade in a class test.
- **Purpose:** Returns the maximum value in a partition.

```sql
SELECT student_id, student_name, subject, marks,
       MAX(marks) OVER(PARTITION BY subject) AS max_marks_in_subject
FROM students;
```

###### 12. CUME_DIST()

- **Analogy:** Shows what percentage of students in your subject scored marks less than or equal to yours, like your position on a class grading curve.
- **Purpose:** Calculates the cumulative distribution (fraction of rows with values <= current row).

```sql
SELECT student_id, student_name, subject, marks,
       CUME_DIST() OVER(PARTITION BY subject ORDER BY marks) AS marks_cumulative_dist
FROM students;
```

###### 13. PERCENT_RANK()

- **Analogy:** In a subject’s marks ranking, shows your relative position as a percentage (0 to 1), like your place in a class leaderboard.
- **Purpose:** Calculates the relative rank of a row within a partition.

```sql
SELECT student_id, student_name, subject, marks,
       PERCENT_RANK() OVER(PARTITION BY subject ORDER BY marks) AS marks_percent_rank
FROM students;
```

###### 14. NTILE(n)

- **Analogy:** Divide students in each subject into n equal groups (e.g., 4 mark tiers) and assign each a group number, like splitting a class into performance quartiles.
- **Purpose:** Divides rows into n buckets within a partition.

```sql
SELECT student_id, student_name, subject, marks,
       NTILE(4) OVER(PARTITION BY subject ORDER BY marks) AS marks_quartile
FROM students;
```

###### All-in-One Query: Show all window functions in a single query

- **Purpose:** Combines all window functions in one query to display their results side by side for each student.

```sql
SELECT student_id
	, student_name
	, subject
	, marks
	, ROW_NUMBER() OVER(PARTITION BY subject ORDER BY student_id) AS row_num
    , RANK() OVER(PARTITION BY subject ORDER BY marks DESC) AS marks_rank
    , DENSE_RANK() OVER(PARTITION BY subject ORDER BY marks DESC) AS dense_marks_rank
    , FIRST_VALUE(student_name) OVER(PARTITION BY subject ORDER BY marks DESC) AS top_scorer
    , LAST_VALUE(student_name) OVER(PARTITION BY subject ORDER BY marks DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lowest_scorer
    , NTH_VALUE(student_name, 2) OVER(PARTITION BY subject ORDER BY marks DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS second_highest_scorer
    , LEAD(student_name) OVER(PARTITION BY subject ORDER BY marks DESC) AS next_lower_scorer
    , LAG(student_name) OVER(PARTITION BY subject ORDER BY marks DESC) AS previous_higher_scorer
    , COUNT(*) OVER(PARTITION BY subject) AS subject_student_count
    , MIN(marks) OVER(PARTITION BY subject) AS min_marks_in_subject
    , MAX(marks) OVER(PARTITION BY subject) AS max_marks_in_subject
    , CUME_DIST() OVER(PARTITION BY subject ORDER BY marks) AS marks_cumulative_dist
    , PERCENT_RANK() OVER(PARTITION BY subject ORDER BY marks) AS marks_percent_rank
    , NTILE(4) OVER(PARTITION BY subject ORDER BY marks) AS marks_quartile
FROM students;
```

