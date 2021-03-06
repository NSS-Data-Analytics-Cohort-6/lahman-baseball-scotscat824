--LAHMAN BASEBALL DATABASE
--Q1: What range of years for baseball games played does the provided database cover?
/*SELECT yearid
FROM appearances
GROUP BY yearid
ORDER BY yearid;
-- A: 1871 - 2016*/

--------------------------------------------------------------------------------------------

--Q2: Find the name and height of the shortest player in the database. How many games
--did he play in? What is the name of the team for which he played
/*SELECT 		namegiven,
			CONCAT('"',namefirst,'"'),
			namelast,
			CONCAT(CAST(FLOOR(height/12) AS numeric(3,0)), ' ft. ', MOD(CAST(height AS integer),12), ' in.') AS ft_in,
			t.name,
			b.yearid,
			b.g,
			b.ab,
			b.h,
			b.bb,
			p.deathyear
FROM people AS p
LEFT JOIN batting AS b
ON b.playerid = p.playerid
LEFT JOIN appearances AS app
ON app.playerid = p.playerid
LEFT JOIN teams AS t
ON app.teamid = t.teamid
GROUP BY namegiven, namefirst, namelast, height, t.name, b.yearid, b.g, b.ab, b.h, b.bb, p.deathyear
HAVING height = (
	SELECT min(height)
	FROM people);*/

	
---------------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------------------

--Q4: Using the fielding table, group players into three groups based on their
--position: label players with position OF as "Outfield", those with position
--"SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C"
--as "Battery". Determine the number of putouts made by each of these three groups in 2016.

--row_number() over (partition by country order by population desc) as country_rank 

/*SELECT 	grouped_pos, SUM(po)
FROM (
		SELECT *,
			CASE WHEN UPPER(pos) LIKE 'P%' OR UPPER(pos) LIKE '%C%'
            THEN 'Battery' 
			WHEN UPPER(pos) LIKE '%1B%' OR UPPER(pos) LIKE '%2B%' OR UPPER(pos) LIKE '%3B%' OR UPPER(pos) LIKE '%SS%'
			THEN 'Infield'
			WHEN UPPER(pos) LIKE '%OF%' OR UPPER(pos) LIKE '%LF%' OR UPPER(pos) LIKE '%CF%' OR UPPER(pos) LIKE '%RF%'
			THEN 'Outfield'
			ELSE 'Utility'
			END AS grouped_pos
		FROM fielding) AS grouping_sub
WHERE yearid = '2016'
GROUP BY grouped_pos*/

------------------------------------------------------------------------------------------------

--Q5: Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places.
--Do the same for home runs per game. Do you see any trends?
/*SELECT decade, CAST(AVG(so_per_game) AS decimal(9,3)) AS average_so_per_game
FROM(
	SELECT *,
		CASE WHEN yearid > 1919 AND yearid < 1930
		THEN '1920s'
		WHEN yearid > 1929 AND yearid < 1940
		THEN '1930s'
		WHEN yearid > 1939 AND yearid < 1950
		THEN '1940s'
		WHEN yearid > 1949 AND yearid < 1960
		THEN '1950s'
		WHEN yearid > 1959 AND yearid < 1970
		THEN '1960s'
		WHEN yearid > 1969 AND yearid < 1980
		THEN '1970s'
		WHEN yearid > 1979 AND yearid < 1990
		THEN '1980s'
		WHEN yearid > 1989 AND yearid < 2000
		THEN '1990s'
		WHEN yearid > 1999 AND yearid < 2010
		THEN '2000s'
		WHEN yearid > 2009 AND yearid < 2020
		THEN '2010s'
		ELSE 'Before'
		END AS decade,
		CAST(so / CAST(g AS decimal(9,3)) AS decimal(9,3)) AS so_per_game
	FROM pitching) AS decades_sub
WHERE yearid > 1919 AND yearid < 2020
GROUP BY decade
ORDER BY decade;*/
-------------------------------------------------------------------------------------------

--Q6:  Find the player who had the most success stealing bases in 2016, where __success__ is measured as the
--percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen
--base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
/*SELECT 	namegiven,
		CONCAT('"',namefirst,'"'),
		namelast,
		sb,
		cs,
		tot_sb_att AS stolen_base_attempts,
		sb_per_game
FROM(
	SELECT 	*,
			(sb+cs) AS tot_sb_att,
			CAST(sb / CAST((sb+cs) AS decimal(9,3)) AS decimal(9,3)) AS sb_per_game
	FROM batting
	WHERE yearid = '2016' AND (sb+cs) >= 20) AS sb_pct_sub
LEFT JOIN people AS p
ON sb_pct_sub.playerid = p.playerid
ORDER BY sb_per_game DESC;*/
-----------------------------------------------------------------------------------------------
--Q7: From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
--What is the smallest number of wins for a team that did win the world series? Doing this will probably
--result in an unusually small number of wins for a world series champion – determine why this is the case.
--Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team
--with the most wins also won the world series? What percentage of the time?

--Largest # wins for a team that did not win the World Series
/*SELECT name, w, yearid
FROM teams
WHERE yearid >= 1970 AND yearid <= 2016 AND wswin = 'N'
GROUP BY w, name, yearid
ORDER BY w DESC;*/
--2001 Seattle Mariners with 116 games

--Smallest # wins for a team that did win the World Series
/*SELECT name, w, yearid
FROM teams
WHERE yearid >= 1970 AND yearid <= 2016 AND wswin = 'Y' AND yearid<>1981 AND yearid<>1972 AND yearid<>1994 AND yearid<>1995
GROUP BY w, name, yearid
ORDER BY w;*/
--1981 Los Angeles Dodgers with 63 wins in a lockout season
--2006 St. Louis Cardinals with 83 wins in a full season

--How often did the team with most wins win the World Series
/*SELECT 	both_ws_and_max_wins,
		all_years,
		CAST(both_ws_and_max_wins / CAST((all_years) AS decimal(9,3)) AS decimal(9,3)) AS pct_max_wins_ws
FROM(
--count and calculation subquery
SELECT 	COUNT(CASE WHEN ws_reg_season_wins = max_reg_season_wins
			 THEN 1
			 END) AS both_ws_and_max_wins,
		COUNT(*) AS all_years
FROM(
--group by max wins, first, then join ws table
SELECT t.yearid, t.name AS ws_winner, t.w AS ws_reg_season_wins, max_wins AS max_reg_season_wins
FROM teams AS t
LEFT JOIN
	(SELECT t.yearid, MAX(t.w) AS max_wins
	FROM teams AS t
	WHERE t.yearid >= 1970 AND t.yearid <= 2016
	GROUP BY t.yearid
	ORDER BY t.yearid) AS max_wins_sub
ON t.yearid = max_wins_sub.yearid
WHERE t.yearid >= 1970 AND t.yearid <= 2016 AND t.wswin = 'Y'
GROUP BY t.yearid, t.name, t.w, max_wins
ORDER BY t.yearid ) AS ws_max_wins_table) AS count_calc_sub*/
--12 times team with most wins won the WS; a .261 effort

-----------------------------------------------------------------------------------------------------


--Q8: Using the attendance figures from the homegames table, find the teams and parks which had
--the top 5 average attendance per game in 2016 (where average attendance is defined as total
--attendance divided by number of games). Only consider parks where there were at least 10 games played.
--Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--parks with most attendance
/*SELECT 	team,
		park_name,
		CAST(AVG(CAST(attendance AS decimal (9,0))/games) AS decimal(9,0)) AS avg_attendance_2016
FROM(
	SELECT *
	FROM parks AS p
	LEFT JOIN homegames AS h
	ON h.park = p.park
	WHERE games > 10 AND h.year = 2016) as park_att
GROUP BY team, park_name, attendance
ORDER BY attendance DESC
LIMIT 5;*/

--parks with least attendance
/*SELECT 	team,
		park_name,
		CAST(AVG(CAST(attendance AS decimal (9,0))/games) AS decimal(9,0)) AS avg_attendance_2016
FROM(
	SELECT *
	FROM parks AS p
	LEFT JOIN homegames AS h
	ON h.park = p.park
	WHERE games > 10 AND h.year = 2016) as park_att
GROUP BY team, park_name, attendance
ORDER BY attendance
LIMIT 5;*/

--------------------------------------------------------------------------------------------------

--Q9: 9. Which managers have won the TSN Manager of the Year award in both the National League (NL)
--and the American League (AL)? Give their full name and the teams that they were managing when they won the award.


/*WITH manager_find (yearid, playerid, awardid, namefirst, namelast, lgid)
AS

(SELECT a.yearid, a.playerid, a.awardid, p.namefirst, p.namelast, a.lgid
FROM awardsmanagers AS a
LEFT JOIN people AS p
ON p.playerid = a.playerid
WHERE a.playerid IN
	(
	SELECT playerid
	FROM(
		SELECT playerid, SUM(NL_awards) AS nl_sums, SUM(AL_awards) AS al_sums
		FROM(

			SELECT 	m.lgid, 
			m.yearid,
			m.playerid,
			m.awardid,
			COUNT(CASE WHEN lgid = 'NL' THEN 1 END) AS NL_awards,
			COUNT(CASE WHEN lgid = 'AL' THEN 1 END) AS AL_awards
			FROM(
				SELECT 	lgid, yearid, playerid, awardid
				FROM awardsmanagers 
				WHERE UPPER(awardid) LIKE '%TSN%' AND UPPER(lgid) <> 'ML'
				GROUP BY lgid, yearid, playerid, awardid) AS m
			GROUP BY m.lgid, m.yearid, m.playerid, m.awardid) AS m_sums
		GROUP BY playerid) AS m_compare
	WHERE nl_sums > 0 AND al_sums > 0)
AND awardid LIKE '%TSN%'),

team_name (year, teamid, team_name, manager)
AS

(select t.yearid, t.teamid, t.name, man.playerid
from teams AS t
left join managers AS man
on man.yearid = t.yearid AND man.teamid = t.teamid
where t.yearid > 1985
group by t.yearid, t.teamid, t.name, man.playerid
order by t.yearid, t.name)


SELECT mf.yearid, mf.awardid, mf.namefirst, mf.namelast, mf.lgid, team_name.team_name
FROM manager_find AS mf
LEFT JOIN team_name
ON mf.yearid = team_name.year AND mf.playerid = team_name.manager
GROUP BY mf.yearid, mf.awardid, mf.namefirst, mf.namelast, mf.lgid, team_name.team_name*/

---------------------------------------------------------------------------------------------------

--Q10: Find all players who hit their career highest number of home runs in 2016. Consider only players
--who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report
--the players' first and last names and the number of home runs they hit in 2016.

SELECT min(DATE_PART('year', CAST(debut AS date))) AS min_year
FROM people
WHERE DATE_PART('year', CAST(finalgame AS date)) > 2015


