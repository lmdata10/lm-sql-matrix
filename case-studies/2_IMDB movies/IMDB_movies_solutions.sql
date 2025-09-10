SELECT * FROM imdb_top_movies;

--- SOLUTION ---

-- 1) Fetch all data from imdb table 
SELECT * FROM imdb_top_movies;


-- 2) Fetch only the name and release year for all movies.

SELECT series_title, released_year
FROM imdb_top_movies;


-- 3) Fetch the name, release year and imdb rating of movies which are UA certified.

SELECT series_title, released_year, imdb_rating
FROM imdb_top_movies
WHERE certificate = 'UA';


-- 4) Fetch the name and genre of movies which are UA certified and have a Imdb rating of over 8.

SELECT series_title, genre
FROM imdb_top_movies
WHERE certificate = 'UA' AND imdb_rating > 8;

-- 5) Find out how many movies are of Drama genre.

SELECT COUNT(*) AS drama_movie_count
FROM imdb_top_movies
WHERE genre LIKE '%Drama%';


-- 6) How many movies are directed by "Quentin Tarantino", "Steven Spielberg", "Christopher Nolan" and "Rajkumar Hirani".

SELECT COUNT(*) AS director_movie_count
FROM imdb_top_movies
WHERE director IN ('Quentin Tarantino', 'Steven Spielberg', 'Christopher Nolan', 'Rajkumar Hirani');

-- 7) What is the highest imdb rating given so far?

SELECT MAX(imdb_rating) AS highest_imdb_rating
FROM imdb_top_movies;

-- 8) What is the highest and lowest imdb rating given so far?

SELECT 
    MAX(imdb_rating) AS highest_imdb_rating,
    MIN(imdb_rating) AS lowest_imdb_rating
FROM imdb_top_movies;

-- 8a) Solve the above problem but display the results in different rows.

SELECT 
    MAX(imdb_rating) AS highest_imdb_rating
FROM imdb_top_movies
UNION ALL
SELECT 
    MIN(imdb_rating) AS lowest_imdb_rating
FROM imdb_top_movies;

-- 8b) Solve the above problem but display the results in different rows. And have a column which indicates the value as lowest and highest.
SELECT 
    MAX(imdb_rating) AS imdb_rating
    , 'Highest rating' AS rating_type
FROM imdb_top_movies
UNION ALL
SELECT 
    MIN(imdb_rating) AS imdb_rating
    , 'Lowest rating' AS rating_type
FROM imdb_top_movies;

-- 9) Find out the total business done by movies staring "Aamir Khan".
SELECT 
    SUM(gross) AS total_business
FROM imdb_top_movies
WHERE 'Aamir Khan' IN (star1, star2, star3, star4);


-- 10) Find out the average imdb rating of movies which are neither directed by "Quentin Tarantino", "Steven Spielberg", "Christopher Nolan" and are not acted by any of these stars "Christian Bale", "Liam Neeson", "Heath Ledger", "Leonardo DiCaprio", "Anne Hathaway".

SELECT 
    AVG(imdb_rating) AS average_imdb_rating
FROM imdb_top_movies
WHERE director NOT IN ('Quentin Tarantino', 'Steven Spielberg', 'Christopher Nolan')
AND ( 'Christian Bale' NOT IN (star1, star2, star3, star4)
    AND 'Liam Neeson' NOT IN (star1, star2, star3, star4)
    AND 'Heath Ledger' NOT IN (star1, star2, star3, star4)
    AND 'Leonardo DiCaprio' NOT IN (star1, star2, star3, star4)
    AND 'Anne Hathaway' NOT IN (star1, star2, star3, star4)
);

-- 11) Mention the movies involving both "Steven Spielberg" and "Tom Cruise".
SELECT 
    series_title, director, star1, star2, star3, star4
FROM imdb_top_movies
WHERE director = 'Steven Spielberg'
AND ('Tom Cruise' IN (star1, star2, star3, star4));


-- 12) Display the movie name and watch time (in both mins and hours) which have over 9 imdb rating.

SELECT series_title
     , runtime AS runtime_mins
     , CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60 AS runtime_hrs
     , ROUND(CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60, 2) AS runtime_hrs_rounded -- for understanding the conversion and wrapping functions.
FROM imdb_top_movies
WHERE imdb_rating > 9;

-- 13) What is the average imdb rating of movies which are released in the last 10 years and have less than 2 hrs of runtime.

-- our approach is to not solve it using hardcoded values but to use the current date and calculate the last 10 years dynamically.
SELECT 
    AVG(imdb_rating) AS average_imdb_rating
FROM imdb_top_movies
WHERE CAST(released_year AS INT) > EXTRACT (YEAR FROM CURRENT_DATE) - 10;

/*
If I run the above query, it will give me an error "invalid input syntax for type integer: "PG".
SELECT * FROM imdb_top_movies
WHERE released_year = 'PG'
There's a string value in the released_year column. So we need to filter out the non-numeric values first.
We can hardcode it with <> 'PG', but we need to make it dynamic.
Regular expressions can be used to filter out non-numeric values.
REGEX is a powerful tool to filter out non-numeric values, but it is also a complicated one
REGEX is used for pattern matching
*/

SELECT 
    ROUND(AVG(imdb_rating),2) AS average_imdb_rating
FROM imdb_top_movies
WHERE CAST(released_year AS INT) > EXTRACT (YEAR FROM CURRENT_DATE) - 10
AND released_year !~ '[^0-9]' -- this regex filters out non-numeric values
-- or hardcode it with AND released_year <> 'PG'
AND CAST(REPLACE(runtime, ' min', '') AS DECIMAL) < 120; -- less than 2 hrs of runtime filter


-- 14) Identify the Batman movie which is not directed by "Christopher Nolan".
SELECT series_title, director
FROM imdb_top_movies
WHERE series_title LIKE '%Batman%'
AND director <> 'Christopher Nolan';


-- 15) Display all the A and UA certified movies which are either directed by "Steven Spielberg", "Christopher Nolan" or which are directed by other directors but have a rating of over 8.

SELECT series_title, certificate, director, imdb_rating
FROM imdb_top_movies
WHERE certificate IN ('A', 'UA')
AND (director IN ('Steven Spielberg', 'Christopher Nolan')
    OR (director NOT IN ('Steven Spielberg', 'Christopher Nolan') AND imdb_rating > 8)
    );

-- 16) What are the different certificates given to movies?

SELECT DISTINCT certificate
FROM imdb_top_movies
WHERE certificate IS NOT NULL;


-- 17) Display all the movies acted by Tom Cruise in the order of their release. Consider only movies which have a meta score.

SELECT series_title, released_year, meta_score
FROM imdb_top_movies
WHERE 'Tom Cruise' IN (star1, star2, star3, star4)
AND meta_score IS NOT NULL
ORDER BY released_year;

/* 
18) Segregate all the Drama and Comedy movies released in the last 10 years as per their runtime. 
Movies shorter than 1 hour should be termed as short film. 
Movies longer than 2 hrs should be termed as longer movies. 
All others can be termed as Good watch time.
*/

SELECT 
    series_title
    , ROUND(CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60,2) AS runtime_hrs
    , CASE 
        WHEN ROUND(CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60,2) < 1 THEN 'Short Film'
        WHEN ROUND(CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60,2) > 2 THEN 'Longer Movie'
        ELSE 'Good Watch Time'
    END AS watch_time_category
FROM imdb_top_movies
WHERE (LOWER(genre) LIKE '%drama%' OR LOWER(genre) LIKE '%comedy%')
AND CAST(released_year AS INT) > EXTRACT (YEAR FROM CURRENT_DATE) - 10
AND released_year !~ '[^0-9+$]'  -- to filter out non-numeric values
-- AND released_year > CAST((EXTRACT (YEAR FROM CURRENT_DATE) - 10) AS VARCHAR)
ORDER BY watch_time_category;

-- 19) Write a query to display the "Christian Bale" movies which released in odd year and even year. Sort the data as per Odd year at the top.

SELECT 
    series_title
    , released_year
    , CASE 
        WHEN CAST(released_year AS INT) % 2 = 0 THEN 'Even Year'
        ELSE 'Odd Year'
    END AS year_type
FROM imdb_top_movies
WHERE 'Christian Bale' IN (star1, star2, star3, star4)
ORDER BY year_type DESC;  

-- 20) Re-write problem #18 without using case statement.

SELECT 
    series_title
    , ROUND(CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60,2) AS runtime_hrs
    , 'Short Film' AS watch_time_category
FROM imdb_top_movies
WHERE (LOWER(genre) LIKE '%drama%' OR LOWER(genre) LIKE '%comedy%')
AND CAST(released_year AS INT) > EXTRACT (YEAR FROM CURRENT_DATE) - 10
AND released_year !~ '[^0-9+$]'
-- AND released_year > CAST((EXTRACT (YEAR FROM CURRENT_DATE) - 10) AS VARCHAR)
AND ROUND(CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60,2) < 1
UNION ALL
SELECT 
    series_title
    , ROUND(CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60,2) AS runtime_hrs
    , 'Good Watch Time' AS watch_time_category
FROM imdb_top_movies
WHERE (LOWER(genre) LIKE '%drama%' OR LOWER(genre) LIKE '%comedy%')
AND CAST(released_year AS INT) > EXTRACT (YEAR FROM CURRENT_DATE) - 10
AND released_year !~ '[^0-9+$]'
-- AND released_year > CAST((EXTRACT (YEAR FROM CURRENT_DATE) - 10) AS VARCHAR)
AND ROUND(CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60,2) BETWEEN 1 AND 2
UNION ALL
SELECT 
    series_title
    , ROUND(CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60,2) AS runtime_hrs
    , 'Longer Movie' AS watch_time_category
FROM imdb_top_movies
WHERE (LOWER(genre) LIKE '%drama%' OR LOWER(genre) LIKE '%comedy%')
AND CAST(released_year AS INT) > EXTRACT (YEAR FROM CURRENT_DATE) - 10
AND released_year !~ '[^0-9+$]'
-- AND released_year > CAST((EXTRACT (YEAR FROM CURRENT_DATE) - 10) AS VARCHAR)
AND ROUND(CAST(REPLACE(runtime, ' min', '') AS DECIMAL) / 60,2) > 2
ORDER BY watch_time_category



-- Extra Assignment:

-- 1) Split the value '1234_1234' into 2 seperate columns having 1234 each.

-- To understand the functions better, let's first solve the lenghty way using both SUBSTRING and POSITION
-- This logic can be applied to any string value with a known delimiter and known position of delimiter.
SELECT
	SUBSTRING('1234_1234', 1, POSITION('_' IN '1234_1234') -1) AS first_part,
	SUBSTRING('1234_1234', POSITION('_' IN '1234_1234') +1) AS second_part

-- Another method
SELECT 
    SUBSTRING('1234_1234' FROM 1 FOR 4) AS first_part,
    SUBSTRING('1234_1234' FROM 6 FOR 4) AS second_part;

-- SPLIT_PART is more flexible and dynamic.
SELECT 
    SPLIT_PART('1234_1234', '_', 1) AS first_part,
    SPLIT_PART('1234_1234', '_', 2) AS second_part; 

-- Another method
SELECT 
    LEFT('1234_1234', 4) AS first_part,
    RIGHT('1234_1234', 4) AS second_part;

-- 2) We see a string value 'PG' in released_year and we hardcoaded it, can we make a query dynamic to identify string value incase if we have multiple string values in-order to ignore those string values
--  Write a query to identify non numeric values in a column.
SELECT DISTINCT released_year
FROM imdb_top_movies
WHERE released_year !~ '^[0-9]+$';  -- This regex filters out non-numeric values

/*
!~: This means "does NOT match". It’s like saying, “If it doesn’t look like what I want, throw it out.”
'^[0-9]+$': This is a special code (called a regular expression) that says, 
“I only want strings that are made of numbers and nothing else.”

^: Says “start here. First place in our case”
[0-9]: Means “any number from 0 to 9.”
+: Means “one or more numbers.”
$: Says “end here. Last position for our case”
^[0-9]+$ means “the whole thing must be just numbers, like ‘2020’, not ‘PG’ or ‘2020a’.”
!~ '^[0-9]+$': Together, this says, “Skip any released_year that isn’t just numbers.”