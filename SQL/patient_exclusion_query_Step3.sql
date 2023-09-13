/***  this is only identifying those who have ever had a smoke record so not going to pick up those who are ex-smokers currently */

drop table if exists smoke_records;
create table smoke_records
SELECT DISTINCT
	patient.registration_guid,
	str_to_date(substr(obs.effective_date,1,10),'%Y-%m-%d') as effective_date,
	cc.snomed_concept_id,
	cc.emis_term
FROM
	patient
INNER JOIN
	observation obs
	ON 
		patient.registration_guid = obs.registration_guid
	INNER JOIN
	clinical_codes cc
	ON 
		obs.snomed_concept_id = cc.snomed_concept_id
		WHERE cc.refset_simple_id = '999004211000230104';

/** since when is copd resolved?? **/

drop table if exists copd_records;
create table copd_records
SELECT DISTINCT
	patient.registration_guid,
	str_to_date(substr(obs.effective_date,1,10),'%Y-%m-%d') as effective_date,
	cc.snomed_concept_id,
	cc.emis_term
FROM
	patient
INNER JOIN
	observation obs
	ON 
		patient.registration_guid = obs.registration_guid
	INNER JOIN
	clinical_codes cc
	ON 
		obs.snomed_concept_id = cc.snomed_concept_id
		WHERE cc.refset_simple_id = '999011571000230107';

/***  WEIGHT ****/

drop table if exists weight_records;
create table weight_records
SELECT DISTINCT
	patient.registration_guid,
	str_to_date(substr(obs.effective_date,1,10),'%Y-%m-%d') as effective_date,
	numericvalue,
	uom,
	snomed_concept_id,
	emis_original_term
FROM
	patient
INNER JOIN
	observation obs
	ON 
		patient.registration_guid = obs.registration_guid
WHERE snomed_concept_id = '27113001';

/** getting the last weight recorded **/

drop table if exists weight_latest;
create table weight_latest
SELECT DISTINCT
wr.registration_guid,
effective_date,
numericvalue,
uom,
snomed_concept_id,
emis_original_term
FROM
weight_records wr
WHERE wr.effective_date = (SELECT MAX(effective_date)
														FROM
															weight_records wd
															WHERE wd.registration_guid = wr.registration_guid);


//**** Last OPT OUT OPTION on a observation record *****/

drop table if exists optout_flag;
create table optout_flag
SELECT DISTINCT
obs1.registration_guid
FROM
observation obs1
WHERE obs1.opt_out_9nd19nu0_flag = 'true' 
AND obs1.effective_date = (SELECT DISTINCT
															max(obs2.effective_date)
														FROM 
															 observation obs2
														WHERE obs2.registration_guid = obs1.registration_guid);


 