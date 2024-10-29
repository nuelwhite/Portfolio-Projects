-- A. Let's begin by getting to know our data. Familiaring with the data is the most critical step in begining analysis on a dataset.

-- 01. show tables
show tables;
/*
	There are 8 tables in the database: data_dictionary, employee, global_water_access, location, visits, water_quality, water_source, well_pollution
*/

-- 02. let's look at data dictionary table
SELECT *
FROM data_dictionary
;
/*
	The data dictioanry table consists of data of the various tables in the database. Each table column has its own decription, datatype, and tables it is related to. 
*/


-- 03. let's look at the location table
SELECT *
FROM location
LIMIT 10;
/*
	Location table consists of 5 columns: location_id, address, province_name, town_name, location_type. The columns are concise and self-explanatory.
*/


-- 04. let's look at the visits table
SELECT *
FROM visits
LIMIT 10;
/*
	Just like all other tables, this table has a clear column names. It contains 7 columns: 
    record_id - unique record ID
    location_id - the unique ID of the location, linked to location table 
    source_id - water source's ID, linked to water sources table
    visit_count - number of times visited
    time_in_queue - time spent in queue to get access to water 
    assigned_employee_id - the employee that visited the sources assigned id, linked to employees table.
*/


-- B. Having gained a basic undertanding with our dataset, let's proceed to understanding the water sources.

-- 01. Let's look at the source to see what kind of water sources we have
SELECT DISTINCT *
FROM water_source
LIMIT 10;
/*
	There are 3 columns in this table: source_id, type_of_water_source, number_of_people_served. There are 5 different types of water sources in the table: 
    tap_in_home - tap in homes working, on average a tap in home serves 6 people.  
    tap_in_home_broken - tap in homes that are broken, 
    well - wells that serve a town or community, 
    shared_tap - taps that are shared by a community or town, 
    river - this is an open source water. 
These are the unique sources of water.
*/


-- 02. let's write a query for the longest time spent in a queue
SELECT *
FROM visits
WHERE time_in_queue > 500
ORDER BY time_in_queue DESC
;
/*
	105 entries were captured to have spent over 500 minutes in queue to get access to water. How would you feel queueing for that long to get access to water? Curious. I am interested in finding which water sources have people spending this long in a queue for. But the visits table does not have any column that tells me which type of water source it is. I will proceed by joining another table.
    visits table looks a like a central table, it is linked to all the various tables. I will proceed and link to the water source table to find the type of water sources. 
*/


-- 03. let's find the types pf water sources that long to queue for.
SELECT vis.record_id, vis.source_id, vis.visit_count, was.type_of_water_source, was.number_of_people_served
FROM visits vis 
JOIN water_source was
ON vis.source_id = was.source_id
WHERE time_in_queue > 400
ORDER BY time_in_queue DESC
LIMIT 5;
/*
	The top 5 entries are all shared taps. Likely that the next 10 will be shared taps. 
*/


-- C. Let us assess the quality of water sources in the dataset. We have a table that contains quality score for each visit made about a water was that was assigned by a Field Surveyor.

-- 01. Let's look through the table record to find the table.
SELECT *
FROM water_quality
LIMIT 5;
/*
	The table contains 3 columns: 
    record_id - record_id from visits table, 
    subjective_quality_score - quality score by the Field Surveyor, 
    visit_count - number of times the water source was visited.
*/


-- It is assumed that the surveyors only visited shared tap sources multiple times and did not revisit other types of water sources. So there should be no records of second visits to locations where the water sources were good - 10. 

-- 02. let's check if surveyors returned to locations with water quality ratings at 10
SELECT *
FROM water_quality
WHERE subjective_quality_score = 10
AND visit_count = 2;
/*
	We can find 218 entries where the quality scores were 10 but the got revisited. What are the reasons? Some employees might have made mistakes. 
*/

-- let's check which water sources were visited twice to get a clearer view.
SELECT waq.record_id, waq.subjective_quality_score, was.type_of_water_source, waq.visit_count
FROM water_quality waq
JOIN visits vis
ON vis.record_id = waq.record_id
JOIN water_source was
ON was.source_id = vis.source_id
WHERE waq.subjective_quality_score = 10
AND waq.visit_count = 2
;
/*
	All the visits that were made twice were all to shared tap sources.
*/


-- D. Familiarizng with the data we discovered that there was table that contained the contamination/pollution data of the well sources, `well_pollution`. 

-- 01. Let's find the pollution table and query a few rows off it.
SHOW TABLES;

SELECT *
FROM well_pollution
LIMIT 10;
/*
	The scientists recored dilligently the water quality of all wells. SOme are contaminated with biological contaminants, while others are polluted with an excess of heavy metals and other pollutants. Based on the results each well was  classified as 
    Clean, 
    Contaminated: Biological,
    Contaminated: Chemical. 
    It is important to know this because wells that are polluted with bio- or other contaminants are not safe to drink. They also recorded the source_id of each test, so we can link it to a source at some place. 
*/


-- The notes were written by the scientists in notebooks, data input persons entered the data digitally, and there might be erroneus data inputed. 

-- 02. Let's write a query to check if the water is contaminated (biological) but noted as Clean.
SELECT *
FROM well_pollution
WHERE biological > 0.01
AND results = "Clean";
/*
	There are 64 entries with errors. These inputs are biologically contaminated but noted as clean. 
    We find that some entries have their description "Clean Bacteria..." which is worng. The description should be "Clean" or others - Bacteria: ...
    We need to find and remove the "Clean" part from the entries because these are all contaminated with bioliogical results > 0.01. 
    Secondly, because the description had the word clean in them, the results were marked clean by the field surveyors. we need to find all the results that have a value greater than 0.01 in biological column and have been set to clean in the results column. 
*/

-- 03. Let's remove rows with description "Clean" where the water source is contaminated

-- let's create a copy of the table before we update it. This is a best practice so that we can go back to the original table incase we miss something
/*
-- CREATE TABLE well_pollution1 AS 
-- SELECT *
-- FROM well_pollution;

-- -- update cloned table
-- UPDATE well_pollution1
-- SET description = SUBSTRING(description, 6) 
-- WHERE description LIKE "Clea%";

-- SELECT * FROM well_pollution1; 
-- did not work
*/
-- CREATE new table
CREATE TABLE well_pollution3 AS 
SELECT *
FROM well_pollution;

-- select data with results clean but polluted biologically. 

SELECT *
FROM well_pollution3
WHERE results =  "Clean"
AND biological > 0.01;

-- update the data
UPDATE well_pollution3
SET description = substring(description, 7)
WHERE description LIKE "Cle%"
AND biological > 0.01;
/*
	38 rows of data were affected. 
*/

-- 04. Let us update the results column with "Clean"
UPDATE well_pollution3 
SET results = "Contaminated: Biological"
WHERE biological > 0.01 AND results = 'Clean';

/*
	All rows are fixed. 
*/