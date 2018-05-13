---
\dt
\l

--create tmp import db
drop table synthea;
create table synthea (
  id text primary key,
  status text,
  data jsonb
);

---
alter table synthea add column status text;

---
truncate synthea;

---

select count(*) from synthea;

---
drop table resource;

---

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'resource_status') THEN
    CREATE TYPE resource_status AS ENUM ('created', 'updated', 'deleted', 'recreated');
  END IF;
END
$$;

CREATE TABLE IF NOT EXISTS resource (
  id text primary key,
  txid bigint not null,
  ts timestamptz DEFAULT current_timestamp,
  resource_type text,
  status resource_status not null,
  resource jsonb not null
);



---
--res tables

CREATE TABLE IF NOT EXISTS Observation (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);
CREATE TABLE IF NOT EXISTS Claim (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);
CREATE TABLE IF NOT EXISTS Encounter (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);
CREATE TABLE IF NOT EXISTS Immunization (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);
CREATE TABLE IF NOT EXISTS Procedure (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);
CREATE TABLE IF NOT EXISTS Condition (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);
CREATE TABLE IF NOT EXISTS MedicationRequest (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);
CREATE TABLE IF NOT EXISTS DiagnosticReport (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);
CREATE TABLE IF NOT EXISTS CarePlan (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);
CREATE TABLE IF NOT EXISTS Goal (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);
CREATE TABLE IF NOT EXISTS Patient (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);
CREATE TABLE IF NOT EXISTS Organization (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);
CREATE TABLE IF NOT EXISTS AllergyIntolerance (id text primary key, txid bigint not null, ts timestamptz DEFAULT current_timestamp, resource_type text, status resource_status not null, resource jsonb not null);

---
create extension pgcrypto

---
truncate resource;
---

with batch as (
  select * from synthea where status is null limit 100
), updated as (
  update synthea set status = 'processed'
  where id in (select id from batch)
  returning id 
)
insert into resource (id, resource_type, txid, resource, status)
select
  coalesce(x.entry#>>'{resource,id}', gen_random_uuid()::text) as id,
  x.entry#>>'{resource,resourceType}',
  0, x.entry->'resource' as resource,
  'created'
  from (
    select jsonb_array_elements(data->'entry') entry from batch
  ) x
ON CONFLICT (id) DO  NOTHING
;

---
-- update synthea set status = null;
select count(*), status from synthea group by status


select resource
from resource
limit 1

---
update resource
set resource = replace(resource::text, 'urn:uuid:', '')::jsonb

---

select count(*) from resource;

-- rt stats
select (resource_type), count(*)
from resource
group by resource_type
order by count(*) desc


---

select jsonb_pretty(resource) from
resource
where resource_type = 'Patient'
limit 10

---

-- extensions

select  ext->'url', count(*)
from (
  select 
  jsonb_array_elements(resource->'extension') as ext
  from resource
  where resource_type = 'Patient'
) _
group by ext->'url'
;


---
select jsonb_pretty(ext)
from (
  select 
  jsonb_array_elements(resource->'extension') as ext
  from resource
  where resource_type = 'Patient'
) _
limit 10
;

---

---

-- "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race"
-- "valueCodeableConcept"
-- "race"

update resource set resource = resource || jsonb_strip_nulls(jsonb_build_object(
 'race', (
    select ext->'valueCodeableConcept' from (
      select jsonb_array_elements(resource->'extension') as ext
    ) _ where ext->>'url' = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race'
    limit 1
  )
))
where resource_type = 'Patient'



---
-- update patient extensions

with mappings (uri, tp, nm) as ( values
  ('http://hl7.org/fhir/us/core/StructureDefinition/us-core-race', 'valueCodeableConcept', 'race'),
  ('http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity', 'valueCodeableConcept','ethnicity'),
  ('http://hl7.org/fhir/StructureDefinition/birthPlace', 'valueAddress','birthPlace'),
  ('http://hl7.org/fhir/StructureDefinition/patient-mothersMaidenName', 'valueString','mothersMaidenName'),
  ('http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex', 'valueCode', 'birthSex'),
  ('http://hl7.org/fhir/StructureDefinition/patient-interpreterRequired', 'valueBoolean', 'interpreterRrequired'),
  ('http://standardhealthrecord.org/fhir/StructureDefinition/shr-demographics-FathersName-extension', 'valueHumanName', 'fathersName'),
  ('http://standardhealthrecord.org/fhir/StructureDefinition/shr-demographics-SocialSecurityNumber-extension', 'valueString', 'socialSecurityNumber')
)

update resource
set resource = resource || 
(
  select jsonb_strip_nulls(ext_obj) FROM (
    select jsonb_object_agg(m.nm, e.ext -> m.tp) as ext_obj from ( 
      select jsonb_array_elements(resource->'extension') as ext
    ) e, mappings m
    where ext->>'url' = m.uri

  ) _
)
where resource_type = 'Patient' 

---
-- why ssn is extension


---
select id,
  resource#>'{name,0,given,0}',
  resource#>'{race,coding,0,display}',
  resource#>'{ethnicity,coding,0,display}',
  resource->>'birthDate'
from resource
where resource_type = 'Patient'
limit 10
;


---
select resource#>'{race,coding,0,display}' race,  count(*)
from resource
where resource_type = 'Patient'
group by resource#>'{race,coding,0,display}'

;

---
select jsonb_pretty(resource)
from resource
where resource_type = 'Patient'
limit 10
;
---
select jsonb_pretty(resource)
from resource
where resource_type = 'Practitioner'
limit 10
;

---
select jsonb_pretty(resource)
from resource
where resource_type = 'Organization'
limit 10
;

---

-- fill the tables
 truncate Observation;
 truncate Claim;
 truncate Encounter;
 truncate Immunization;
 truncate Procedure;
 truncate Condition;
 truncate MedicationRequest;
 truncate DiagnosticReport;
 truncate CarePlan;
 truncate Goal;
 truncate Patient;
 truncate Organization;
 truncate AllergyIntolerance;
;


INSERT INTO Observation select * from resource where resource_type = 'Observation';
INSERT INTO Claim select * from resource where resource_type = 'Claim';
INSERT INTO Encounter select * from resource where resource_type = 'Encounter';
INSERT INTO Immunization select * from resource where resource_type = 'Immunization';
INSERT INTO Procedure select * from resource where resource_type = 'Procedure';
INSERT INTO Condition select * from resource where resource_type = 'Condition';
INSERT INTO MedicationRequest select * from resource where resource_type = 'MedicationRequest';
INSERT INTO DiagnosticReport select * from resource where resource_type = 'MedicationReport';
INSERT INTO CarePlan select * from resource where resource_type = 'CarePlan';
INSERT INTO Goal select * from resource where resource_type = 'Goal';
INSERT INTO Patient select * from resource where resource_type = 'Patient';
INSERT INTO Organization select * from resource where resource_type = 'Organization';
INSERT INTO AllergyIntolerance select * from resource where resource_type = 'AllergyIntolerance';

---

-- select resource from patient limit 1;

select k, count(*) from (
  select jsonb_object_keys(resource) as k
  from observation
) _
group by k

---
-- fix polymorphic

update observation
set resource = resource || jsonb_build_object(
  'value', jsonb_strip_nulls(jsonb_build_object(
    'string', resource->'valueString',
    'CodeableConcept', resource->'valueCodeableConcept',
    'Quantity', resource->'valueQuantity')))
    ;

---
select
jsonb_pretty(resource->'value'),
jsonb_pretty(resource->'subject')
from observation
limit 5
;

---

select jsonb_pretty(resource)
from patient
limit 1
;

---

select jsonb_pretty(resource)
from encounter
limit 1
;

---

\i h.psql
select :pp(resource)
from organization
limit 1
;

---

\i h.psql

select distinct :keys(resource) k
from patient
;

---
select distinct jsonb_object_keys(resource) k
from encounter
;

---
\i h.psql
select distinct :keys(resource) k
from CarePlan
;


---

select 'select * from ' || rt || ' limit 1'
from (
  select distinct resource_type as rt
  from resource
) _
\gexec


---

truncate synthea;
truncate resource;
