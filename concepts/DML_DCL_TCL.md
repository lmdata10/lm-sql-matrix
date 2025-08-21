# ***Session: DML, DCL, TCL***

---

## `TRUNCATE` (**DDL**) & `DELETE` (**DML**)

 `TRUNCATE` empties the table and removes all records permanently while keeping the table structure.

```sql
TRUNCATE TABLE employees WHERE salary < 1000;
-- This is not going to work

TRUNCATE TABLE employees; -- Will work
```

## DML, DCL, TCL

`DELETE` is used to delete records that matches a certain filter condition or we can delete directly

```sql
DELETE FROM employees WHERE salary < 1000;
-- This will work fine, and it's the best use of DELETE

DELETE FROM employees; -- This would also work fine BUT
```

Here we had only 10-15 records so the `DELETE FROM employees;` query is fine, but imagine if we have to d  o that in real world, real world org data has millions and millions of rows where this query would take hours to run. Not efficient.
What we can do instead is use the `TRUNCATE` command it empties the table faster.

Internally how delete works in SQL is that it will run row by row, whereas the internal operation of SQL when using truncate is that recreates the table structure. So running Truncate doesn't depend on how many rows of data we have it is independent of that and doesn't have to run row by row.

## `UPDATE`  - DML

```sql
UPDATE employees
SET salary = salary + 100, name = name || ' ***'
WHERE salary > 10000;
```

>[!tip]
>
>- Always use a filter condition when using `UPDATE` or `DELETE` Commands or even try performing a select statement first to verify the records you are trying to delete or update.
>- We don't want to end up updating wrong records or all records in our database, if that a production database containing millions and millions of rows you'll end up updating all records and that is going to cause you problems.

---

*Day 2 learning completed*