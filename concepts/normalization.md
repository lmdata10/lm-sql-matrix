
# **Normalization**

**What is normalization?**
Think of normalization like **organizing your books**:

* You don’t want the same book in five different places.
* Everything should have **one correct spot**.
* This keeps your room neat and easy to manage.

In a **bank database**, normalization is about keeping customer, account, and branch info neat so the bank doesn’t mess up.

---

## **Why We Need It – The Problems (Anomalies)**

If the bank just writes everything in one big table, bad things can happen:

| Customer Name | Account Number | Branch   | Branch Address | Balance |
| ------------- | -------------- | -------- | -------------- | ------- |
| Alice         | 123            | Downtown | 1 Main St      | 5000    |
| Bob           | 124            | Downtown | 1 Main St      | 3000    |
| Alice         | 125            | Uptown   | 2 High St      | 7000    |

### **Types of Problems (Anomalies):**

1. **Update Anomaly** – If the Downtown branch moves, you have to change **all rows** that say “Downtown”. Forget one, the data is wrong.
2. **Insert Anomaly** – You can’t add a new branch without creating a fake account first.
3. **Delete Anomaly** – If Bob closes his account and he’s the only customer at Downtown, deleting him would also delete the branch info!

Normalization fixes these.

---

## **Step 1: 1NF – First Normal Form**

**Rule:** Make every piece of info small and separate (atomic) and give each row a **unique ID**.

**Tables:**

**Customers**

| Customer ID | Name  |
| ----------- | ----- |
| 1           | Alice |
| 2           | Bob   |

**Branches**

| Branch ID | Name     | Address   |
| --------- | -------- | --------- |
| 1         | Downtown | 1 Main St |
| 2         | Uptown   | 2 High St |

**Accounts**

| Account Number | Customer ID | Branch ID | Balance |
| -------------- | ----------- | --------- | ------- |
| 123            | 1           | 1         | 5000    |
| 124            | 2           | 1         | 3000    |
| 125            | 1           | 2         | 7000    |

✅ Now rows are **unique**, and no big messy cells.

---

## **Step 2: 2NF – Second Normal Form**

**Rule:** All info must depend on the **whole key**, not just part of it.

* Helps when a table has **two or more columns as primary key**.
* Reduces repeated info and mistakes.

**Example:** If “Balance” depends only on Account Number, not the whole key, we separate it.

---

## **Step 3: 3NF – Third Normal Form**

**Rule:** Info should depend only on the **main key**, not on other columns.

**Example:**

* Branch Address depends on Branch Name, not Account Number → move it to Branch table.

✅ Fixes **update anomalies**.

---

## **Step 4: 4NF – Fourth Normal Form**

**Rule:** No column should have **multiple independent values** in one row.

**Example:**

* A customer has multiple phone numbers → make a **Customer Phones** table.

---

## **Step 5: 5NF – Fifth Normal Form**

**Rule:** Break tables further so **joining them rebuilds the original table** perfectly.

* Used for tricky many-to-many relationships, like customers, branches, and services.

---

## **Constraints (Rules to Keep Data Safe)**

* **Primary Key (PK):** Unique ID for each row
* **Foreign Key (FK):** Makes sure a value exists in another table
* **Unique:** No duplicates
* **Not Null:** Must have a value
* **Check:** Value must follow a rule

---

## **Summary Table**

| Step | What We Do                       | Why                                         |
| ---- | -------------------------------- | ------------------------------------------- |
| 1NF  | Make columns small, unique IDs   | Avoid messy cells                           |
| 2NF  | Remove partial dependencies      | Avoid repeated info                         |
| 3NF  | Remove transitive dependencies   | No column depends on another non-key column |
| 4NF  | No multiple values in one cell   | One fact per place                          |
| 5NF  | Break tricky many-to-many tables | Can rebuild original table perfectly        |

**Anomalies Fixed:**

* Update → change info in one place
* Insert → add new info easily
* Delete → delete without losing other info

![alt](/=images/normalization.png)
---

