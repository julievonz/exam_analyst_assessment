/*** EXTRACT ALL THE RECORDS NEEDED FOR INCLUSION CRITERIA **/
/**  Asthma records */
 
DROP TABLE IF EXISTS asthma_patients;
CREATE TABLE asthma_patients
SELECT DISTINCT
	patient.registration_guid,
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
		WHERE cc.refset_simple_id = '999012891000230104';

/** Identify all the inclusion medications ***/

	drop table if exists pat_incl_medications;
	create table pat_incl_medications as 
	SELECT DISTINCT
  registration_guid,
	str_to_date(substr(effective_date,1,10),'%Y-%m-%d') as effective_date,
	medication.snomed_concept_id,
	medication.emis_original_term
FROM
	medication
	WHERE 
	(medication.snomed_concept_id IN ('129490002','108606009','702408004','702801003','704459002') ) OR
	(
	(medication.emis_original_term LIKE '%Formoterol%') OR
	(medication.emis_original_term LIKE '%Salmeterol Xinafoate%') OR
	(medication.emis_original_term LIKE '%Vilanterol%') OR
	(medication.emis_original_term LIKE '%Indacaterol%') OR
	(medication.emis_original_term LIKE '%Olodaterol%') );
	
  INSERT INTO pat_incl_medications
	WITH parent_codes_tbl AS 
	(SELECT
	  parent_code_id,
	  snomed_concept_id,
    emis_term
	FROM
	clinical_codes
	WHERE 
	snomed_concept_id IN ('129490002','108606009','702408004','702801003','704459002') )
	(SELECT DISTINCT
  registration_guid,
	str_to_date(substr(effective_date,1,10),'%Y-%m-%d') as effective_date,
	medication.snomed_concept_id,
	medication.emis_original_term
FROM
  medication
INNER JOIN 
	clinical_codes ON medication.emis_code_id = clinical_codes.code_id
INNER JOIN parent_codes_tbl ON clinical_codes.parent_code_id = parent_codes_tbl.parent_code_id);
	
	ALTER TABLE pat_incl_medications
	ADD INDEX (registration_guid);
	 
		