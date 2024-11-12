Create database Netflix;
use Netflix;
drop database Netflix;

CREATE TABLE netflix (
  show_id VARCHAR(10) PRIMARY KEY,
  type VARCHAR(20) NOT NULL,
  title VARCHAR(255) NOT NULL,
  director VARCHAR(255) NULL,  
  cast TEXT NULL,              
  country VARCHAR(150) NULL,   
  date_added VARCHAR(50) NULL,
  release_year INT NOT NULL,
  rating VARCHAR(10) NULL,
  duration VARCHAR(50) NULL,
  listed_in TEXT NULL,
  description TEXT NULL
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix_titles.csv' 
INTO TABLE netflix 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(show_id, type, title, director, cast, country, date_added, release_year, rating, duration, listed_in, description);

select count(*) as total_count from netflix;
select * from netflix;
select distinct type from netflix;


-- 15 Business Problems

-- 1. Count the number of Movies vs TV Shows
select type, 
count(*) as Total_content
from netflix
group by type;


-- 2. Find the most common rating for movies and TV Shows
select type, rating
from
(select type, rating, 
count(*) as total, 
rank() over(partition by type order by count(*) desc) as ranking
from netflix
group by type, rating
) as t1
where ranking = 1;


-- 3. List all movies released in a specific year (eg., 2020)
select type,title, release_year 
from
(select * from netflix
where type = "Movie") as T1
where release_year = 2020;
-------------------------------------
select * from netflix
where type = "Movie" and release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix
select distinct SUBSTRING_INDEX(country, ',', 1) AS new_country,
count(show_id) as Total_content
FROM netflix 
group by 1
order by 2 desc
limit 5


-- 5. Identify the longest movie?
select * from netflix
where type = "Movie"
and 
duration = (select max(duration) from netflix)


-- 6.  Find Content added in the last 5 years(doubt)
SELECT *
FROM netflix
where STR_TO_DATE(date_added, '%M %d, %Y') >= Curdate() - Interval 5 Year


-- 7. Find all the movies/TV Shows by director 'Rajiv Chilaka'
select * from netflix
where director like "%Rajiv Chilaka%"


-- 8. List all the TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;


-- 9. Count the number of content items in each genre(listed_in).
select SUBSTRING_INDEX(listed_in, ',', 1) AS genre,
count(show_id) as Total_content
FROM netflix 
group by 1


-- 10.  find each year and the average numbers of content release by India on netflix.
-- Return the top 5 year with the highest average content release.

select * from netflix
where country = "India"


-- 11. List all movies that are documentaries.
select * from netflix
where listed_in like "%documentaries%"


-- 12. Find all content without a director
select * from netflix
where director is null;
----------------------------
SELECT *
FROM netflix
WHERE director IS NULL OR director = '';


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years?
select * from netflix
where cast like "%Salman khan%"
and
release_year > year(curdate()) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in india.
-- (doubt)

select SUBSTRING_INDEX(cast, ',') AS actors,
count(*) as Total_content
from netflix
where country like "%India%"
group by 1
order by 2 desc
limit 10;


-- 15. Categorize the content based on the presence of the keywords 'Kill' and 'voilence' in
-- the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'.
-- Count how many items fall into each category.

with cte as
(
select *,
case when
	description like "%kill%" or
    description like "Voilence" then "Bad_content"
    else "Good_content"
    end category
from netflix
)
select category,
count(*) as total_content
from cte
group by category
