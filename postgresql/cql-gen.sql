---
DROP TABLE cql;
CREATE TABLE IF NOT EXISTS cql (
  id text primary key,
  row_number bigint,
  resource jsonb not null
);


---

truncate cql;

---

\i h.psql

with pts as (
  insert into cql (row_number,id,resource)
  select row_number() OVER (), id, resource from patient
  where resource->>'gender' = 'female'
  and age((resource->>'birthDate')::timestamp) between '12 years' and '64 years'
  limit 30
  returning *
), encs as (
  insert into cql (row_number, id,resource)
  select row_number() OVER (), e.id, e.resource
  from encounter e, patient p
  where e.resource#>>'{subject,reference}' = p.id 
  limit 30
  returning *
),  proc_codes as (
  select row_number() OVER (), c.* from
  (
    select *
    from concept
    where resource->>'valueset' in ('2.16.840.1.113883.3.464.1004.1208', '2.16.840.1.113883.3.464.1004.1208.23')
    order by random()
  ) c
),  procs as (
  insert into cql (id,resource)
  select :uuid,
  :o(
      'code', :o(
          'coding', :a(
                 :o('code', pc.resource->>'code',
                    'system', pc.resource->>'system',
                    'display', pc.resource->>'display')
          )
      ),
      'status', 'completed',
      -- 'context', :o('reference', p.id),
      'subject', :o('reference', p.id),
      'resourceType', 'Procedure',
      'performedDateTime', '2018-02-23T05,08,47+03,00'
  ) from pts p
  join proc_codes pc on pc.row_number = p.row_number 
  returning *
) , diag as (
  insert into cql (id,resource)
  select  :uuid,
  :o('resourceType', 'DiagnosticReport',
    'status', 'final',
    'code', :o(
      'coding', :a(
        :o('code', pc.resource->>'code',
        'system', pc.resource->>'system',
        'display', pc.resource->>'display')
      )
    ),
    'subject', :o( 'reference', p.id ),
    'issued', '2013-05-15T19,32,52+01,00',
    'conclusion', 'Core lab'
  )
  from pts p
  join proc_codes pc on p.row_number = pc.row_number
  returning *
), obs as (
  insert into cql (id,resource)
  select  :uuid,
  :o('code', :o(
         'text', 'Sexual orientation',
         'coding', :a(
            :o('code', pc.resource->>'code',
               'system', pc.resource->>'system',
               'display', pc.resource->>'display')
         )
     ),
     'value', :o(
         'string', 'heterosexual'
     ),
     'issued', '2014-03-28T19,21,30.949+04,00',
     'status', 'final',
     -- 'context', :o('reference', e.id),
     'subject', :o('reference', p.id),
     'valueString', 'heterosexual',
     'resourceType', 'Observation',
     'effectiveDateTime', '2014-03-28T19,21,30+04,00'
 )
 from pts p
 join proc_codes pc on p.row_number = pc.row_number
 returning *

)
select resource from obs;
---
insert into cql (id,resource)
select id,resource || '{"resourceType":"Concept"}' from concept
;

---
\i h.psql

COPY (select resource || :o('id', id) from cql)
TO '/data/cql.csv';

-- select * from obs
-- ;


---

insert into procedure (id,txid,status,resource)
select id,0, 'created', resource from cql
where resource->>'resourceType' = 'Procedure'

---

insert into diagnosticreport (id,txid,status,resource)
select id,0, 'created', resource from cql
where resource->>'resourceType' = 'DiagnosticReport'

---

insert into observation (id,txid,status,resource)
select id,0, 'created', resource from cql
where resource->>'resourceType' = 'Observation'

---
