## PostgreSQL & jsonb

### Summary


THE WORLD'S MOST ADVANCED OPEN SOURCE RELATIONAL DATABASE
which support binary JSON as datatype

With PostgreSQL you can get both document jsonb storage & power of SQL + transactional
guarantees.



### Bootstrap

You need docker-compose


```
git clone https://github.com/fhir-fuel/fhir-storage-and-analytics-track/

cd postgresql

docker-compose up -d

source init.sh

curl https://storage.googleapis.com/fhir-storage/synthea.gz | gunzip | psql synthea

psql 
> \td
> select * from patient limit 1
```


### Store and Retrieve FHIR resource


We use the following schema to store FHIR resources:


```sql

CREATE TABLE IF NOT EXISTS patient (
  id text primary key, -- resource id 
  txid bigint not null, -- logical transaction id used for reactive scenarios
  ts timestamptz DEFAULT current_timestamp, -- updated datetime
  resource_type text, -- resource type
  status resource_status not null, -- created,updated,deleted
  resource jsonb not null -- json fhir resource
);


INSERT INTO patient (id, txid, resource_type, status, resource) 
values ('pt-1', 0, 'Patient', 'created', '{"name": [{"given": ["Nikolai"]}]}');

SELECT resource FROM patient;

```

### Search by resource elements

How to search specific resourceType by specific element


```sql

SELECT resource 
FROM patient
WHERE resource#>>'{name,0,given}' ilike 'Niko%'
;


SELECT resource 
FROM patient
WHERE 
  resource#>>'{name,0,given}' ilike 'Niko%'
AND 
  resource->>'birthDate'::timestamp > '1970'
;

```

### Related resources

How to represent references between resources

How to search and retrieve related resources




### Analytic


More complicated queries with aggregation etc


```
mc cp synthea.gz uhn/fhir-storage/synthea.gz
pg_dump synthea | gzip > synthea.gz

gunzip -c synthea.gz | psql synthea
cat synthea.gz | gunzip | psql synthea
```
