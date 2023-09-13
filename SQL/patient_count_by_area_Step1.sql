/***  GET rid of empty postcodes and extracting the first part of postcode */

drop table if exists clean_data_tbl;
create temporary table clean_data_tbl
( SELECT CASE postcode WHEN '' THEN NULL ELSE substr( postcode, 1, locate(' ',postcode,1)-1) END AS area, 
gender, 
registration_guid FROM patient );

drop table if exists total_tbl;
create temporary table total_tbl
(SELECT
area,
count(registration_guid) as total_per_area
FROM
	clean_data_tbl 
WHERE
	area IS NOT NULL 
GROUP BY
	area);

DROP TABLE IF EXISTS patient_counts_per_area;
CREATE TABLE patient_counts_per_area AS 
SELECT 
c.area,
gender,
count( registration_guid ) AS counts,
t.total_per_area,
count( registration_guid ) / t.total_per_area * 100 as perc
FROM
clean_data_tbl c,
total_tbl t
WHERE c.area = t.area
GROUP BY 
c.area, gender
ORDER BY t.total_per_area DESC;

/***  this version of MariaDB does not support using LIMIT etc in a subquery so thats why I am using temp tbls*/

drop table if exists best_area;
CREATE TEMPORARY TABLE best_area
SELECT DISTINCT
area
FROM
patient_counts_per_area
LIMIT 0,2;

drop table if exists patients_selected;
create table patients_selected 
SELECT
 registration_guid,
 postcode
 FROM patient,
 best_area pca
 WHERE substr( postcode, 1, locate(' ',postcode,1)-1) = pca.area;
 
 alter table patients_selected
 add primary key (registration_guid);
 


	
	