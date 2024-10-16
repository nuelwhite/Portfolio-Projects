-- show tables
show tables;

-- let's look at data dictionary table
SELECT *
FROM data_dictionary
;

-- let's look st the location table
SELECT *
FROM location
LIMIT 10;

-- let's look at the visits table
SELECT *
FROM visits
LIMIT 10;

-- Let's look at the source to see what kind of water sources we have
SELECT DISTINCT type_of_water_source
FROM water_source
LIMIT 10;

-- let's write a query for the longest time spent in a queue
SELECT *
FROM visits
WHERE time_in_queue > 400
;

-- let's find the maximum mintes spent queueing 
SELECT *
FROM visits
WHERE time_in_queue > 400
ORDER BY time_in_queue DESC
LIMIT 5;

-- let's finf the types pf water sources that long to queue for.
SELECT vis.record_id, vis.source_id, vis.visit_count, was.type_of_water_source, was.number_of_people_served
FROM visits vis 
JOIN water_source was
ON vis.source_id = was.source_id
WHERE time_in_queue > 400
ORDER BY time_in_queue DESC
LIMIT 5;

-- Let's look through the table record to find the table.
show tables;

SELECT *
FROM water_quality
LIMIT 5;

-- let's check if surveyors returned to locations with water quality ratings at 10
SELECT *
FROM water_quality
WHERE subjective_quality_score = 10
AND visit_count = 2;

SELECT waq.record_id, waq.subjective_quality_score, was.type_of_water_source, waq.visit_count
FROM water_quality waq
JOIN visits vis
ON vis.record_id = waq.record_id
JOIN water_source was
ON was.source_id = vis.source_id
WHERE waq.subjective_quality_score = 10
AND waq.visit_count = 2
;

-- Let's find the pollution table and query a few rows off it.
SHOW TABLES;

SELECT *
FROM well_pollution
LIMIT 10;

-- Let's write a query to check if the water is contaminated but noted as Clean.
SELECT *
FROM well_pollution
WHERE biological > 0.01
AND results = "Clean";

-- Let's remove rows descriptions with "Clean" 
UPDATE well_pollution
SET `description` = SUBSTRING(description, 2) 
WHERE `description` LIKE " %";