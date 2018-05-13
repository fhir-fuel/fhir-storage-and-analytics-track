---
select * from diagnosticreport  limit 10

---
select resource->'code' from observation  limit 10

---

select
  pr.resource,
  p.resource->>'gender',
  age((p.resource->>'birthDate')::timestamp )
from patient p

join procedure pr on pr.resource#>>'{subject,reference}' = p.id
and pr.resource#>>'{code,coding,0,code}' in ('valueset')

join procedurerequest prq on prq.resource#>>'{subject,reference}' = p.id
and prq.resource#>>'{code,coding,0,code}' in ('valueset')

join observation obs on obs.resource#>>'{subject,reference}' = p.id
and obs.resource#>>'{code,coding,0,code}' in ('valueset')

where p.resource->>'gender' = 'female'
and age((p.resource->>'birthDate')::timestamp) between '12 years' and '64 years'

limit 4
