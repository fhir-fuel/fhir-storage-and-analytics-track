---
-- see pg jsonb documentation 
-- https://www.postgresql.org/docs/10/static/functions-json.html

select resource
from patient
limit 1
;


---

-- see names
select
  (resource#>>'{name,0,given,0}')::text || ' ' || (resource#>>'{name,0,family}')::text
from patient
limit 5
;

---
-- search by start with
select resource->'name'
from patient
where
  (resource#>>'{name,0,given,0}')::text || ' ' || (resource#>>'{name,0,family}')::text
   ilike '% Abbott%'
limit 5
;

---
-- search by birthDate
select (resource->>'birthDate')::timestamp
from patient
limit 5 
;

-- search by birthDate
select resource#>'{name,0,family}', resource->>'birthDate'
from patient
where (resource->>'birthDate')::timestamp between '1970-01-01'::timestamp and  '1975-01-01'::timestamp
limit 5
;

---

\i h.psql

select :pp(resource->'value'), :pp(resource)
from observation
where resource#>>'{value,Quantity}' is not null
limit 10

