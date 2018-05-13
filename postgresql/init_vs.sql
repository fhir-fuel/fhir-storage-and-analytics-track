---
create extension pgcrypto
---
CREATE TYPE resource_status AS ENUM ('created', 'updated', 'deleted', 'recreated');
---
drop table vss;
create table vss (
id text primary key,
status text,
data jsonb
);
---
CREATE TABLE IF NOT EXISTS Concept
(id text primary key,
 txid bigint not null,
 ts timestamptz DEFAULT current_timestamp,
 resource_type text,
 status resource_status not null,
 resource jsonb not null);
---
truncate table vss

---
truncate table concept
---
insert into Concept (id, txid, resource, status)
select
gen_random_uuid()::text,
0,
jsonb_build_object('valueset', replace(data#>>'{expansion, identifier}', 'http://fhir.ext.apelon.com/dtsserverws/fhir/ValueSet/', ''))
||
jsonb_array_elements(data#>'{expansion, contains}'),
'created'
from vss

---
select resource
from Concept
limit 10

---
select distinct resource->>'valueset'
from concept
order by resource->>'valueset'
