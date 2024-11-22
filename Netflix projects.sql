-- Netflix TV Show and movies

SELECT * FROM Netflix_pro;

--15 bysiness problems

-- 1. Count the no of Movies vs TV Shows

SELECT  type , count(type) as total_content 
from Netflix_pro
GROUP BY type;

-- 2. Find the most common rating for movies and tv shows

SELECT type, rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS cnt, -- Alias added for COUNT(*)
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM Netflix_pro
    GROUP BY type, rating -- Explicit column names used
) AS t1
WHERE ranking = 1;
 

 select type, rating 
from 
(
  SELECT 
     type,
     rating ,
     count(*) as cnt,
     RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
  from Netflix_pro
  GROUP BY type, rating
) as t1
WHERE
     ranking = 1; 

	 -- 3. List all movies released in a specific year (eg., 2020)

	 SELECT * FROM Netflix_pro
	 WHERE type = 'Movie' AND release_year = 2020;

-- 4. Find the top 5 countries with the most content on netflix

SELECT TOP 5
    LTRIM(RTRIM(value)) AS country,
    COUNT(show_id) AS total_content
FROM Netflix_pro
CROSS APPLY STRING_SPLIT(country, ',') AS new_country
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_content DESC;

-- 5. Identify the longest movie?

SELECT * FROM Netflix_pro
WHERE type = 'Movie'
AND duration = (SELECT MAX (duration) from Netflix_pro
)

-- 6 Find the content added in the last 5 year

 SELECT *,
    PARSE(date_added AS DATE USING 'en-US') AS converted_date
FROM Netflix_pro
WHERE PARSE(date_added AS DATE USING 'en-US') >= DATEADD(YEAR, -5, GETDATE());

-- 7. Find all the movies and tv shows directed by 'Rajiv Chilaka'

SELECT * from Netflix_pro
where director LIKE '%Rajiv Chilaka%'

-- 8 . List all TV Shows with more than 5 seasons


SELECT *
FROM Netflix_pro
WHERE type = 'TV Show'
AND CAST(SUBSTRING(duration, 1, PATINDEX('%[^0-9]%', duration) - 1) AS INT) > 5;


-- 9. count the number of content items in each genre

SELECT 
    LTRIM(RTRIM(value)) AS genra,
	COUNT(show_id) AS total_content
FROM Netflix_pro
CROSS APPLY STRING_SPLIT(listed_in, ',') AS new_listed_in
Group by LTRIM(RTRIM(value)) ;

--10. Find the each year and the average number of content released by India on Netflix, returan top 5 year with highst avd content released


 SELECT 
   YEAR(PARSE(date_added AS DATE USING 'en-US')) AS converted_date,
   COUNT(*) AS total_content,
   ROUND(
      CAST(COUNT(*) AS FLOAT) / 
      (SELECT CAST(COUNT(*) AS FLOAT) FROM Netflix_pro WHERE country = 'India') * 100, 
      2
   ) AS Avg_total_content
FROM Netflix_pro
WHERE country = 'India'
GROUP BY YEAR(PARSE(date_added AS DATE USING 'en-US'));

-- 11. List all the movies that are documentries

SELECT * FROM Netflix_pro
WHERE type= 'Movie' AND listed_in like '%Documentaries%';

--12. find all content withoiut director

SELECT * FROM Netflix_pro
WHERE director IS NULL;


--13.  Find how many movies actor 'Salman Khan' appeared in last 10 years .


SELECT * 
FROM Netflix_pro
WHERE 
   cast LIKE '%Salman Khan%' 
   AND release_year > YEAR(DATEADD(YEAR, -10, GETDATE()));

-- 14. find the top 10 actors have appeared in the highest number of movies produced in india.

 SELECT TOP 10
 LTRIM(RTRIM(value)) as actors,
 count(*) as total_content
 from Netflix_pro
 CROSS APPLY STRING_SPLIT (cast, ',') AS cast
 WHERE country LIKE '%India'
 GROUP BY LTRIM(RTRIM(value))
 ORDER BY total_content DESC;


 --15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

 WITH new_table
 AS
 ( SELECT 
 * ,
 CASE
  WHEN 
     descriPtion LIKE '%Kill%'  OR
	  descriPtion LIKE '%voilence%'  then 'Bad'
	  ELSE 'Good'
	  END category
FROM Netflix_pro
)
SELECT
   category,
   COUNT(*) as total_content
from new_table
GROUP BY category;