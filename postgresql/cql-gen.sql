---

\i h.psql

with

names (nm,gen) as (values
('Vladimir', 'M'),
('Edic', 'M'),
('Ivan', 'M'),
('Ignat','M'),
('Olga','F'),
('Alina','F'),
('Elena','F'),
('Andrey', 'M')),
families (fm) as (values ('Ivanov'), ('Ignatov'), ('Andreev')),
birth_years (by) as (values ('1950'), ('1960'), ('1970'), ('1980')),
races (rc) as (values ('White'), ('Asian'), ('African'))

select
:o(
  'resourceType', 'Patient',
  'name', :a(:o('given', :a(nm), 'family', fm)),
  'gender', gen,
  'birthDate', by,
  'race', rc
)
from names names, families, birth_years,races
;


-- value tables
--  value, probability per 1000, meta
--  names
-- 'David', 5, {gender: 'M'} 

-- address = state + city + street + home + room => 1 or 2
-- birthdate = year + month + day => used 1000



---
with
_names (nm,gend, gen) as (values
  ('Nikolai', 'M', 30),
  ('Nikita', 'M', 50),
  ('Albert', 'M', 5),
  ('Ivan', 'M', 50),
  ('Andrey', 'M', 70),
  ('Edip', 'M', 2)
),
_families (fm, gen) as (values
  ('Nikolaev',  5),
  ('Kutis',  1),
  ('Ivanov',  50),
  ('Sundukov',  30),
  ('Lisny',  30),
  ('Efremov',  50)
),
names as (
  select row_number() OVER (), nm from (
    select * from (
      select nm, generate_series(1, gen)
      from _names
    ) _ order by random()
  ) _
),
families as (
  select row_number() OVER (), fm from (
    select * from (
      select fm, generate_series(1, gen)
      from _families
    ) _ order by random()
  ) _
)

select * from names
join families using (row_number)


