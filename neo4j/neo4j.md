## My technology

### Summary

My technology is document database bla, bla
It's cool in .....
We store FHIR resources this way....



### Bootstrap

How to  setup env and load data into database



### Store and Retrieve FHIR resource


Short description of database schema 
Example how to store and retrieve resource from you database


```sql

INSERT INTO patient (id, resource) 
values ('pt-1', '{"name": [{"given": ["Nikolai"]}]}');

SELECT resource FROM patient;

```

### Search by resource elements

How to search specific resourceType by specific element


```sql

SELECT resource 
FROM patient
WHERE resource#>>'{name,0,given}' ilike 'Niko%'
;

```
More complicated queries




```sql

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
