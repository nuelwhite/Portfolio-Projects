/* 
	Clustering Data to Unveil Maji Ndogo's Water Crisis.
In this project we will cluster our data, stepping back from individual figures to gain panoramic understanding. This bird's eye view will allow us to unearth broader narratives and hidden correlations concealed within our rich dataset.
*/ 

-- Before we start, let's go through our data dictionary, and query through some tables to get the feeling of the data again. 
SELECT *
FROM data_dictionary;

SELECT *
FROM global_water_access
LIMIT 10;

SELECT *
FROM employee;
-- we can see that there are empty fields in the email column. 


-- 01. Cleaning Our Data. 
-- From the previous query, we can see that there empty email columns which need to be fixed. We will clean and fix that column. The email is supposed to  be first_name.last_name @ndogowater.gov 


-- A. Email column
SELECT *
FROM employee;

SELECT CONCAT(LOWER(REPLACE(employee_name, " ",".")), "@ndogowater.gov") AS new_email
FROM employee;

UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, " ",".")), "@ndogowater.gov");


-- B. phone_number column. Most often when data is collected from various sources errors creep in. In this case, the phone_number column is stores as a string datatype. And phone numbers are definite, they have a total number of digits. Let's check this.

SELECT LENGTH(phone_number)
FROM employee;
-- There are 13 characters indicating that there is an extra character. phone-numbers are supposed to be 12 characters plus the area code, and + sign. 

UPDATE employee
SET phone_number = TRIM(phone_number);


-- 02. Honoring the workers. The president will like to honor dedicated workers for their commitment towards the project.

-- Let's check how many of our employees live in each town.
SELECT *
FROM employee;

SELECT town_name, COUNT(town_name) AS No_of_Employees
FROM employee
GROUP BY town_name
ORDER BY 2 DESC;
-- 29 people live in Rural, and  lives in Kintampo, and Yaounde. 

-- Let's use the employee_ids to get the names, email and phone numbers of the three field surveyors with the most location visits. 
SELECT *
FROM employee;

SELECT * 
FROM visits
LIMIT 10;

SELECT e.assigned_employee_id, e.employee_name,e.email, e.phone_number, COUNT(v.visit_count) AS visit_count
FROM employee e
JOIN visits v
ON e.assigned_employee_id = v.assigned_employee_id
WHERE e.position = "Field Surveyor"
GROUP BY e.assigned_employee_id, e.employee_name,e.email, e.phone_number
ORDER BY 5 DESC
LIMIT 3;

/* 1	Bello Azibo	bello.azibo@ndogowater.gov	+99643864786	3708
30	Pili Zola	pili.zola@ndogowater.gov	+99822478933	3676
34	Rudo Imani	rudo.imani@ndogowater.gov	+99046972648	3539 
These are the top 3 employees with the most visits to locations. They are the surveyors being honored. 
*/


-- 03. Analysing Locations. 

-- A. Let's write a query to count the number of records per town.
SELECT *
FROM location
LIMIT 4;

SELECT *
FROM visits
limit 4; 
-- we will join both tables on location_id to write this query

SELECT l.town_name ,COUNT(v.record_id) AS no_of_records
FROM location l
JOIN visits v
ON l.location_id = v.location_id
GROUP BY l.town_name
ORDER BY 2 DESC;
-- There are 38741 records belonging to rural, the highest. Most of our records are situated in small rural communities, scattered across the country.

-- B. Let's check the records per province
SELECT l.province_name, COUNT(v.record_id) AS no_of_records
FROM location l
JOIN visits v
ON l.location_id = v.location_id
GROUP BY l.province_name
ORDER BY 2 DESC;


-- C. Let's count the records for each province, and town. 
SELECT l.province_name, l.town_name, COUNT(v.record_id) AS no_of_records
FROM location l
JOIN visits v
ON l.location_id = v.location_id
GROUP BY l.province_name, l.town_name
ORDER BY 1, 3;

-- Let us look at the number of records per location type
SELECT l.location_type, COUNT(v.record_id) AS no_of_records
FROM location l
JOIN visits v
ON l.location_id = v.location_id
GROUP BY l.location_type
ORDER BY 2 DESC;
-- we can see that there are more rural sources than urban. but it is really hard to understand those numbers. Percentages are more relatable. Let's convert them to percentage.

-- come back later


-- 04. Diving into Water Sources
SELECT * 
FROM water_source
LIMIT 10;
/*
	Water sources is a big table. It contains data about the type of water sources, and the number of people it serves.
*/

-- A. How many people did we serve in total?
SELECT COUNT(source_id) AS no_of_surveys
FROM water_source;
-- There are 39650 total surveys

-- B. How many wells, taps and rivers are there?
SELECT type_of_water_source, COUNT(type_of_water_source) AS count_of_sources
FROM water_source
GROUP BY type_of_water_source;

-- C. How many people share particular types of water sources on average?
SELECT type_of_water_source, ROUND(AVG(number_of_people_served)) AS avg_of_people
FROM water_source
GROUP BY type_of_water_source;
-- An average of 2071 people shared taps. 

-- D. How many people are getting water from each type of source?
SELECT type_of_water_source, SUM(number_of_people_served) AS people_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY 2 DESC;
-- 11M people are getting water from shared taps. 

-- convert them tompercentages


-- 05. Start of a Solution
/*
	At some point we will have to fix or improve all of the infrastructure, so we should start thinking about how we can make a data-driven decision.
    We will write a query that ranks each type of source based on how many people use it. We will use window functions, RANK().
*/

-- A.  Let's rank each type of water source based on the number of people served.
SELECT type_of_water_source, SUM(number_of_people_served) AS total_served, RANK() OVER(ORDER BY SUM(number_of_people_served) DESC) AS `rank`
FROM water_source
GROUP BY type_of_water_source;
/* So we should fix shared taps first, then walls, and so on. But the question is which shared taps or wells should be fixed first? We can use the same logic; the most used soirces should really be fixed first.
*/

-- B. Let's find what we should be fixing first per water type.
SELECT source_id, type_of_water_source, number_of_people_served, DENSE_RANK() OVER(PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_rank 
FROM water_source
ORDER BY 2; 


-- 06. Analyzing Queues.
/*
	During exploration we noticed that the visits table documented all of the visits of our field officers. For most sources, one visit was enough, but if there were queues, they visited the location a couple times to get a good idea of the time it took for people to queue for water. So we have the time that they collected the data, how many times the site was visited, and how long people had to queue for water. 
*/
SELECT * 
FROM visits
LIMIT 5;

-- we will be using advanced functions like date, control flow, and time functions.
SELECT DATE(time_of_record)
FROM visits;

-- A. How long did the survey take?
SELECT MAX(time_of_record) AS end_date, MIN(time_of_record) AS start_date, datediff(MAX(time_of_record), MIN(time_of_record)) AS Number_of_Days
FROM visits;
-- The survey lasted 924 days which is 2 and half years. They survey started 2021-01-01 at 9:10 and ended at 13:53 on 2023-07-14.


-- B. What is the average total queue time for water?
SELECT AVG(v.time_in_queue) AS avg_time_in_queue
FROM visits v
JOIN water_source w
ON v.source_id = w.source_id
WHERE time_in_queue != 0
-- w.type_of_water_source NOT IN ( "tap_in_home", "tap_in_home_broken")
;/*
	with tap in homes, people do not need to queue to get water, thus the 0 time spent in queue. Adding the 0 during the arithmetic operation changes the average value. People spend about 123 minutes averagely in queue for water. Imagine spending that much time in a queue to get water. 
*/

-- C. What is the average queue time on different days?
SELECT DAYNAME(time_in_queue) AS `Day`, ROUND(AVG(time_in_queue)) AS avg_time_in_queue
FROM visits v
JOIN water_source w
WHERE DAYNAME(time_in_queue) != 0 
AND w.type_of_water_source NOT IN ('tap_in_home', 'tap_in_home_broken')
GROUP BY DAYNAME(time_in_queue)
ORDER BY 1 DESC
; 


-- Let's look at what time during the day people queue for water
SELECT HOUR(time_of_record) AS hour_of_day, ROUND(AVG(time_in_queue)) AS avg_time_in_queue
FROM visits
GROUP BY HOUR(time_of_record)
ORDER BY 1
;
/*
	The higher average time people spend in queues are during 19:00, but the numbers do not explain a lot. Fixing them in a proper time format can help with clarity.
*/
SELECT TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day, ROUND(AVG(time_in_queue)) AS avg_time_in_queue
FROM visits
GROUP BY TIME_FORMAT(TIME(time_of_record))
ORDER BY 1;


-- D. How can we communicate this information efficiently?

