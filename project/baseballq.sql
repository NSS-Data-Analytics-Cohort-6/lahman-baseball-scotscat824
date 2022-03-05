--LAHMAN BASEBALL DATABASE
--Q1: What range of years for baseball games played does the provided database cover?
/*SELECT yearid
FROM appearances
GROUP BY yearid
ORDER BY yearid;
-- A: 1871 - 2016*/

--Q2: Find the name and height of the shortest player in the database. How many games
--did he play in? What is the name of the team for which he played
/*SELECT 	namefirst,
		namelast,
		CONCAT(CAST((height / 12) AS number(1,0) ' ft')
FROM people
WHERE height = (
	SELECT min(height)
	FROM people);*/

--Q3: Find all players in the database who played at Vanderbilt University. Create a list
--showing each player’s first and last names as well as the total salary they earned in
--the major leagues. Sort this list in descending order by the total salary earned.
--Which Vanderbilt player earned the most money in the majors?
--A: David Price; $81,851,296

/*SELECT namefirst, namelast, sum(salary) AS totalsal
FROM people AS p
LEFT JOIN salaries AS sal
ON sal.playerid = p.playerid
WHERE p.playerid IN
	(SELECT playerid
	FROM collegeplaying AS cp
	WHERE EXISTS
		(SELECT *
	 	FROM schools AS s
	 	WHERE schoolname LIKE '%Vanderbilt%' AND s.schoolid = cp.schoolid))
GROUP BY namelast, namefirst
ORDER BY totalsal DESC;*/

--Q4: Using the fielding table, group players into three groups based on their
--position: label players with position OF as "Outfield", those with position
--"SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C"
--as "Battery". Determine the number of putouts made by each of these three groups in 2016.

--row_number() over (partition by country order by population desc) as country_rank 

/*SELECT 	grouped_pos, SUM(po)
FROM (
		SELECT *,
			CASE WHEN pos LIKE UPPER('P%') OR pos LIKE UPPER('%C%')
            THEN 'Battery' 
			WHEN pos LIKE UPPER('%1B%') OR pos LIKE UPPER('%2B%') OR pos LIKE UPPER('%3B%') OR pos LIKE UPPER('%SS%')
			THEN 'Infield'
			WHEN pos LIKE UPPER('%OF%') OR pos LIKE UPPER('%LF%') OR pos LIKE UPPER('%CF%') OR pos LIKE UPPER('%RF%')
			THEN 'Outfield'
			ELSE 'Utility'
			END AS grouped_pos
		FROM fielding) AS grouping_sub
WHERE yearid = '2016'
GROUP BY grouped_pos*/

	 


