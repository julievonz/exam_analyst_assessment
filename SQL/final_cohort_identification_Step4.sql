ALTER TABLE patients_selected
ADD COLUMN asthma char(1) null,
ADD COLUMN meds char(1) null,
ADD COLUMN smoker char(1) null,
ADD COLUMN weight char(1) null,
ADD COLUMN COPD char(1) null,
ADD COLUMN optout char(1) null;

UPDATE patients_selected,
asthma_patients
SET asthma = '1'
WHERE 
patients_selected.registration_guid = asthma_patients.registration_guid;

UPDATE patients_selected,
pat_incl_medications
SET meds = '1' 
WHERE 
patients_selected.registration_guid = pat_incl_medications.registration_guid
AND effective_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 YEAR);

/** checking the dates 
SELECT
ps.registration_guid,
DATE_SUB(CURRENT_DATE(), INTERVAL 30 YEAR) as start_date,
effective_date
FROM
patients_selected ps,
pat_incl_medications pm
WHERE 
ps.registration_guid = pm.registration_guid
and effective_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 YEAR);
****/

/*** The refset is only providing smoker codes not the non-smoker / ex-smoker codes so this isn't able to determine if the patient is actually CURRENTLY SMOKING */

UPDATE patients_selected,
smoke_records
SET smoker = '1'
WHERE 
patients_selected.registration_guid = smoke_records.registration_guid;

UPDATE patients_selected
SET copd = null;

UPDATE patients_selected,
copd_records
SET copd = '1'
WHERE 
patients_selected.registration_guid = copd_records.registration_guid;

UPDATE patients_selected,
weight_latest
SET weight = '1'
WHERE 
patients_selected.registration_guid = weight_latest.registration_guid
AND numericvalue < 40 
AND uom = 'Kg';
/*** IF in stones/pounds, would need to do calc */


UPDATE patients_selected,
optout_flag
SET optout = '1'
WHERE patients_selected.registration_guid = optout_flag.registration_guid;

/*** FINAL COHORT SELECTION - Need to Build a consort diagram to display the counts for incl/excl ****/

SELECT 
patient.registration_guid,
concat(patient.patient_givenname,' ',patient_surname) as full_name,
patient.postcode,
age,
gender
FROM
patients_selected
INNER JOIN patient USING (registration_guid)
WHERE optout IS NULL ##1842
AND asthma = '1' ## 28
AND meds = '1' ## 1
AND smoker IS NULL ## 1
AND weight IS NULL ## 1
AND COPD IS NULL; ## 0







