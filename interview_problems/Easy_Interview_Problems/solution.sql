/****************************************************************
PROBLEM 1 
****************************************************************/

-- Write an SQL query to transform given input data into the expected output. Output can be sorted in any order.
SELECT * FROM drivers;

SELECT 
    COALESCE (t1.driver1, '') AS DRIVER1
    , COALESCE(t2.driver2, '') AS DRIVER2
FROM drivers t1
FULL JOIN drivers t2
    ON t1.driver1 = t2.driver2

/****************************************************************
PROBLEM 2
****************************************************************/

-- Write an SQL query to transform given input data into the expected output. Output can be sorted in any order.

SELECT * FROM all_names;

--  ============================
--  SQL Server
--  ============================

SELECT * 
FROM all_names 
WHERE names LIKE '%[^A-Za-z]%';


-- Explanation:
LIKE            ==> Pattern matching operator in SQL Server.
%               ==> Wildcard for zero or more characters.
[^A-Za-z]       ==> Any one character not between A to Z (uppercase or lowercase).
'%[^A-Za-z]%'   ==> Pattern matches strings containing at least one non-alphabetic character.


--  ============================
--  Databricks (Spark SQL)
--  ============================

SELECT * 
FROM all_names 
WHERE NOT (names RLIKE '^[A-Za-z]+$');

-- Explanation:
RLIKE       ==> Means REGEX search in Databricks/Spark SQL. Searches for a match based on given pattern.
NOT         ==> Reverse of match (kind of NOT LIKE).
^           ==> Indicates starting character.
[A-Za-z]    ==> Any one character between alphabets A to Z in both uppercase and lowercase.
+           ==> Indicates one or more occurrences of the previous character set (ensures at least one letter).  
$           ==> Indicates the last character must be the pattern provided prior to $ symbol.


/****************************************************************
PROBLEM 3
****************************************************************/

-- Identify the student who always outscored themselves in each semester.


SELECT * FROM student_marks

with cte as 
	(select *
	, CASE WHEN prcntg > lead(prcntg) over(partition by ID Order by semester) 
				then 1 else 0 end flag
	from student_marks)
select student_name--, sum(flag)
from cte
group by student_name
having sum(flag) = 0;

/****************************************************************
PROBLEM 4
****************************************************************/



/****************************************************************
PROBLEM 5
****************************************************************/





/****************************************************************
PROBLEM 6
****************************************************************/








/****************************************************************
PROBLEM 7
****************************************************************/








/****************************************************************
PROBLEM 8
****************************************************************/









/****************************************************************
PROBLEM 9
****************************************************************/








/****************************************************************
PROBLEM 10
****************************************************************/
