SELECT * FROM Album; -- 347
SELECT * FROM Artist; -- 275
SELECT * FROM Customer; -- 59
SELECT * FROM Employee; -- 8
SELECT * FROM Genre; -- 25
SELECT * FROM Invoice; -- 412
SELECT * FROM MediaType; -- 5
SELECT * FROM Track; -- 3503
SELECT * FROM Playlist; -- 18
SELECT * FROM PlaylistTrack; -- 8715
SELECT * FROM InvoiceLine; -- 2240






/********************************************************************************
1) Find the artist who has contributed with the maximum no of albums. Display the artist name and the no of albums.
********************************************************************************/

WITH CTE AS(
SELECT 
    artistid
    ,COUNT(albumid) AS count_of_albumns
    ,RANK() OVER (ORDER BY COUNT(albumid) DESC) AS alb_rnk
FROM Album
GROUP BY artistid
)

SELECT 
    a.name
    ,cte.count_of_albumns
FROM CTE
JOIN artist a
    ON a.artistid = cte.artistid
WHERE cte.alb_rnk = 1;

/********************************************************************************
2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.
********************************************************************************/

SELECT 
    c.firstname || ' ' || c.lastname AS CustomerName
    ,c.email AS EmailId
    ,c.country
FROM customer c
JOIN invoice i ON i.customerid = c.customerid
JOIN invoiceline il ON il.invoiceid = i.invoiceid
JOIN track t ON il.trackid = t.trackid
JOIN genre g ON g.genreid = t.genreid
WHERE g.name IN ('Jazz', 'Rock', 'Pop');


/********************************************************************************
3) Find the employee who has supported the most no of customers. Display the employee name and designation
********************************************************************************/

WITH emp_support AS(
SELECT
    supportrepid
    , COUNT(customerid) AS total_customers_supported
    , RANK() OVER (ORDER BY COUNT(customerid) DESC) AS rnk
FROM customer
GROUP BY supportrepid
)

SELECT
    e.firstname || ' ' || e.lastname AS EmployeeName
    ,e.title AS Designation
FROM emp_support es
JOIN employee e ON e.employeeid = es.supportrepid
WHERE es.rnk = 1;


/********************************************************************************
4) Which city corresponds to the best customers?
********************************************************************************/

WITH city_rnk_by_revenue AS(
SELECT
    billingcity
    , SUM(total) AS total_revenue_generated
    , RANK() OVER (ORDER BY SUM(total) DESC) AS rnk
FROM invoice
GROUP BY billingcity
)

SELECT
    billingcity AS City_with_best_customers
FROM city_rnk_by_revenue
WHERE rnk = 1;


/********************************************************************************
5) The highest number of invoices belongs to which country?
********************************************************************************/

-- Let's solve this one using subquery
SELECT country
FROM (
    SELECT
        billingcountry AS country
        ,COUNT(1) AS no_of_invoice
        ,RANK() OVER(ORDER BY COUNT(1) DESC) AS rnk
    FROM Invoice
    GROUP BY billingcountry
) sub
WHERE sub.rnk = 1;

-- for quick check you can opt for a simple query with limit, same can be applied to above questions as well.
SELECT billingcountry
FROM invoice
GROUP BY billingcountry
ORDER BY COUNT(invoiceid) DESC
LIMIT 1;

/********************************************************************************
6) Name the best customer (customer who spent the most money).
********************************************************************************/


SELECT
    cx.firstname || ' ' || cx.lastname AS CustomerName
FROM (
    SELECT
        customerid
        , SUM(total) AS total_money_spent
        , RANK() OVER (ORDER BY SUM(total) DESC) AS rnk
    FROM invoice
    GROUP BY customerid
) sub
JOIN customer cx
    ON cx.customerid = sub.customerid
WHERE rnk = 1;



/********************************************************************************
7) Suppose you want to host a rock concert in a city and want to know which location should host it.
********************************************************************************/

-- Query the dataset to find the city with the most rock-music listeners

SELECT
    billingcity AS city
    , COUNT(i.invoiceid) AS total_sales
FROM invoice i
JOIN invoiceline il 
    ON il.invoiceid = i.invoiceid
JOIN track t 
    ON il.trackid = t.trackid
JOIN genre g 
    ON g.genreid = t.genreid
WHERE g.name = 'Rock'
GROUP BY billingcity
ORDER BY total_sales DESC;

/********************************************************************************
8) Identify all the albums who have less then 5 track under them.
    Display the album name, artist name and the no of tracks in the respective album.
********************************************************************************/

SELECT
    a.title AS AlbumName
    ,at.name AS ArtistName
    , COUNT(t.trackid) AS no_of_tracks
FROM album a
JOIN track t
    ON a.albumid = t.albumid
JOIN artist at 
    ON at.artistid = a.artistid
GROUP BY a.title,at.name
HAVING COUNT(t.trackid) < 5

-- CTE Solution
WITH AlbumTrackCount AS (
    SELECT 
        a.albumid
        ,a.title AS AlbumName
        ,at.name AS ArtistName
        ,COUNT(t.trackid) AS no_of_tracks
    FROM album a
    JOIN track t ON a.albumid = t.albumid
    JOIN artist at ON at.artistid = a.artistid
    GROUP BY a.albumid, a.title, at.name
)
SELECT 
    AlbumName
    ,ArtistName
    ,no_of_tracks
FROM AlbumTrackCount
WHERE no_of_tracks < 5;

/********************************************************************************
9) Display the track, album, artist and the genre for all tracks which are not purchased.
********************************************************************************/

SELECT
    t.name AS Track
    , alb.title AS Album
    , a.name AS Artist
    , g.name AS Genre
FROM artist a
JOIN album alb 
    ON alb.artistid = a.artistid
JOIN track t 
    ON t.albumid = alb.albumid
JOIN genre g 
    ON g.genreid = t.genreid
LEFT JOIN invoiceline il 
    ON il.trackid = t.trackid
WHERE il.invoiceid IS NULL;

-- NOT EXISTS Solution (Preferred)
-- stops at first match (short-circuits), better performance, clearer intent for anti-joins
-- Check out the SQL Intermediate Co-related subquery notes for explanation.

SELECT 
    t.name AS track_name,
    al.title AS album_title,
    art.name AS artist_name,
    g.name AS genre
FROM Track t
JOIN album al ON al.albumid = t.albumid
JOIN artist art ON art.artistid = al.artistid
JOIN genre g ON g.genreid = t.genreid
WHERE NOT EXISTS (
    SELECT 1
    FROM InvoiceLine il
    WHERE il.trackid = t.trackid
);

SELECT 1
    FROM InvoiceLine il
    WHERE il.trackid = 7

/************************************************
Co-related Subquery with EXISTS & NOT EXISTS

Example 1: TrackID = 7 (NOT EXISTS = TRUE)

STEP 1: Main query has Track 7

TrackID | Track Name    | Album      | Artist  | Genre
--------|---------------|------------|---------|-------
7       | Some Cool Song| Rock Album | RockBand| Rock

STEP 2: Subquery checks InvoiceLine

SELECT 1 FROM InvoiceLine WHERE il.trackid = 7
InvoiceLine table result: (Empty - No rows found)

STEP 3: NOT EXISTS evaluation
- Subquery returned 0 rows
- EXISTS = FALSE
- NOT EXISTS = TRUE ✓
- Track 7 is INCLUDED in final result ✓

Example 2: TrackID = 2 (NOT EXISTS = FALSE)

STEP 1: Main query has Track 2

TrackID | Track Name        | Album      | Artist | Genre
--------|-------------------|------------|--------|-------
2       | Stairway to Heaven| Led Zep IV | LedZep | Rock

STEP 2: Subquery checks InvoiceLine

SELECT 1 FROM InvoiceLine WHERE il.trackid = 2
InvoiceLine table result:

InvoiceLineID | InvoiceID | TrackID | Quantity
--------------|-----------|---------|----------
45            | 10        | 2       | 1
78            | 15        | 2       | 1

STEP 3: NOT EXISTS evaluation
- Subquery returned 2 rows (but stops after finding first row)
- EXISTS = TRUE
- NOT EXISTS = FALSE ✗
- Track 2 is EXCLUDED from final result ✗
- Final Result of entire query:

TrackID | Track Name    | Album      | Artist  | Genre
--------|---------------|------------|---------|-------
7       | Some Cool Song| Rock Album | RockBand| Rock
Only Track 7 appears (never sold). Track 2 is filtered out (was sold).

*************************************************/


/********************************************************************************
10) Find artist who have performed in multiple genres. Diplay the aritst name and the genre.
********************************************************************************/

WITH cte AS(
    SELECT
        art.name AS ArtistName
        ,g.name as GenreName
    FROM artist art
    JOIN album al ON al.artistid = art.artistid
    JOIN track t ON t.albumid = al.albumid
    JOIN genre g ON g.genreid = t.genreid
    GROUP BY art.name, g.name
)
, cte2 AS(
    SELECT
        ArtistName
    FROM cte
    GROUP BY ArtistName
    HAVING COUNT(ArtistName) > 1
)
SELECT
    c1.*
FROM cte c1
JOIN cte2 c2
    ON c2.ArtistName = c1.ArtistName
ORDER BY ArtistName, GenreName;


/********************************************************************************
11) Which is the most popular and least popular genre?
********************************************************************************/

WITH temp AS (
    SELECT 
        DISTINCT g.name
        ,COUNT(1) AS no_of_purchases
        ,RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM InvoiceLine il
    JOIN Track t ON t.TrackId = il.TrackId
    JOIN Genre g ON g.GenreId = t.GenreId
    GROUP BY g.name
    ORDER BY 2 DESC
)
,temp2 AS (
    SELECT 
        MAX(rnk) AS max_rnk FROM temp
)
SELECT
    name AS genre
    ,CASE WHEN rnk = 1 THEN 'Most Popular' ELSE 'Least Popular' END AS popular
FROM temp
CROSS JOIN temp2
WHERE rnk = 1 OR rnk = max_rnk;

-- Solution using INNER JOIN

WITH temp AS (
    SELECT 
        g.name AS genre
        ,COUNT(1) AS no_of_songs
        ,RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM InvoiceLine il
    JOIN Track t 
        ON t.TrackId = il.TrackId
    JOIN Genre g 
        ON g.GenreId = t.GenreId
    GROUP BY g.name
    ORDER BY 2 DESC
)
,max_rank AS (
    SELECT 
        MAX(rnk) AS max_rnk FROM temp
)
SELECT 
    genre
    ,no_of_songs
    ,CASE WHEN rnk = 1 THEN 'Most Popular' ELSE 'Least Popular' END AS Popular_Flag
FROM temp
INNER JOIN max_rank 
    ON rnk = max_rnk OR rnk = 1;


/********************************************************************************
12) Identify if there are tracks more expensive than others. If there are then
    display the track name along with the album title and artist name for these expensive tracks.
 ********************************************************************************/   

2


/********************************************************************************
13) Identify the 5 most popular artist for the most popular genre.
    Popularity is defined based on how many songs an artist has performed in for the particular genre.
    Display the artist name along with the no of songs.
    [Reason: Now that we know that our customers love rock music, we can decide which musicians to invite to play at the concert.
    Lets invite the artists who have written the most rock music in our dataset.]
********************************************************************************/

WITH most_popular_genre AS (
    SELECT
        name AS genre
    FROM (
        SELECT
            g.name
            ,COUNT(1) AS no_of_purchases
            ,RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
        FROM InvoiceLine il
        JOIN Track t 
            ON t.TrackId = il.TrackId
        JOIN Genre g 
            ON g.GenreId = t.GenreId
        GROUP BY g.name
        ORDER BY 2 DESC
    ) x
    WHERE rnk = 1
)
,all_data AS (
    SELECT 
        art.name AS artist_name
        ,COUNT(1) AS no_of_songs
        ,RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM Track t
    JOIN Album al 
        ON al.AlbumId = t.AlbumId
    JOIN Artist art 
        ON art.ArtistId = al.ArtistId
    JOIN Genre g 
        ON g.GenreId = t.GenreId
    WHERE g.name IN (SELECT genre FROM most_popular_genre)
    GROUP BY art.name
    ORDER BY 2 DESC
)
SELECT 
    artist_name
    ,no_of_songs
FROM all_data
WHERE rnk <= 5;


/********************************************************************************
14) Find the artist who has contributed with the maximum no of songs/tracks. Display the artist name and the no of songs.
********************************************************************************/

SELECT 
    name
FROM (
    SELECT 
        ar.name
        ,COUNT(1)
        ,RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM Track t
    JOIN Album a 
        ON a.AlbumId = t.AlbumId
    JOIN Artist ar 
        ON ar.ArtistId = a.ArtistId
    GROUP BY ar.name
    ORDER BY 2 DESC
) x
WHERE rnk = 1;


/********************************************************************************
15) Are there any albums owned by multiple artist?
********************************************************************************/

SELECT 
    AlbumId
    ,COUNT(1) AS records
FROM Album
GROUP BY AlbumId
HAVING COUNT(1) > 1;

-- No albums found

/********************************************************************************
16) Is there any invoice which is issued to a non existing customer?
********************************************************************************/

SELECT 
    invoiceid
FROM Invoice I
WHERE NOT EXISTS (
    SELECT 1 FROM Customer c
    WHERE c.CustomerId = I.CustomerId
);


/********************************************************************************
17) Is there any invoice line for a non existing invoice?
********************************************************************************/

SELECT 
    *
FROM InvoiceLine IL
WHERE NOT EXISTS (
    SELECT 1 FROM Invoice I
    WHERE I.InvoiceId = IL.InvoiceId
);


/********************************************************************************
18) Are there albums without a title?
********************************************************************************/

SELECT 
    COUNT(*)
FROM Album  -- Result is 0, meaning there are no albums without a title.
WHERE Title IS NULL;


/********************************************************************************
19) Are there invalid tracks in the playlist?
********************************************************************************/

SELECT 
    *
FROM PlaylistTrack pt  -- Result is 0, meaning all tracks in playlists are valid.
WHERE NOT EXISTS (
    SELECT 1 FROM Track t
    WHERE t.TrackId = pt.TrackId
);
