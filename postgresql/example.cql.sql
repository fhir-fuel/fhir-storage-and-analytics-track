-- /*
-- Description
-- The percentage of women 21-64 years of age who were screened for cervical
-- 		cancer using either of the following criteria:
-- 	* Women 21-64 years of age who had cervical cytology performed every 3 years.
-- 	* Women 30-64 years of age who had cervical cytology/human papillomavirus
-- 		(HPV) co-testing performed every 5 years.
-- */

-- valueset "Cervical Cytology Value Set": '2.16.840.1.113883.3.464.1004.1208' // Grouping
-- define "Dates of Cervical Cytology Tests":
-- 	([Procedure: "Cervical Cytology Value Set"] Proc
-- 		where Proc.status.value = 'completed'
-- 		return PeriodToIntervalOfDT(Proc.performed))
-- 	union
-- 	([DiagnosticReport: "Cervical Cytology Value Set"] DiagRep
-- 		where DiagRep.status.value in { 'preliminary', 'final', 'amended', 'corrected', 'appended' }
-- 		return PeriodToIntervalOfDT(DiagRep.effective))
-- 	union
-- 	([Observation: "Cervical Cytology Value Set"] Obs
-- 		where Obs.status.value in { 'final', 'amended' }
-- 		return DateTimeToInterval(Obs.effective))
---

with Cervical_Cytology_Value_Set  (code) as (
  select resource->>'code'
  from concept
  where resource->>'valueset' = '2.16.840.1.113883.3.464.1004.1208'
)
select
  p.resource->>'gender',
  p.resource#>>'{name,0,family}',
  age((p.resource->>'birthDate')::timestamp ),
  pr.resource#>>'{code,coding,0,display}'
from patient p

join procedure pr
  on pr.resource#>>'{subject,reference}' = p.id
join Cervical_Cytology_Value_Set p_vs
  on p_vs.code = pr.resource#>>'{code,coding,0,code}'

join diagnosticreport prq
  on prq.resource#>>'{subject,reference}' = p.id
 and prq.resource#>>'{code,coding,0,code}' in (select code from Cervical_Cytology_Value_Set )

join observation obs
  on obs.resource#>>'{subject,reference}' = p.id
 and obs.resource#>>'{code,coding,0,code}' in (select code from Cervical_Cytology_Value_Set )

where p.resource->>'gender' = 'female'
  and age((p.resource->>'birthDate')::timestamp) between '12 years' and '64 years'

limit 5

