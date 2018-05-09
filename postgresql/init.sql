---
\dt
\l

--create tmp import db
drop table synthea;
create table synthea (
  id text primary key,
  data jsonb
);


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

\set record `cat synthea/Abbott701_Norman373_77.json`

insert into synthea (id, data)
values ('Abbott701_Norman373_77.json', :'record');

---
create extension pgcrypto

---
truncate resource;

insert into resource (id, resource_type, txid, resource, status)
select
  coalesce(x.entry#>>'{resource,id}', gen_random_uuid()::text) as id,
  x.entry#>>'{resource,resourceType}',
  0,
  x.entry->'resource' as resource,
  'created'
  from (
    select jsonb_array_elements(data->'entry') entry from synthea
  ) x
ON CONFLICT (id) DO  NOTHING
;
---
select resource
from resource
limit 1

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

-- "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race"
-- "valueCodeableConcept"
-- "race"

update resource
set resource = resource || jsonb_build_object('race',
(
  select ext->'valueCodeableConcept' from (
    select jsonb_array_elements(resource->'extension') as ext
  ) _
  where ext->>'url' = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race'
  limit 1
)
)
where resource_type = 'Patient'




-- why ssn is extension 


---
select id, resource#>'{name,0,given}',
  resource#>'{race,coding,0,display}'
from resource
where resource_type = 'Patient'
limit 10;

