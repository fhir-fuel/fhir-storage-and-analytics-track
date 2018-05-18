## SQL Server with a Vonk Database Schema

### Summary

Vonk FHIR Server can be run in Memory, on MongoDB and on SQL Server. For the Storage and Analytics track on Connectathon 18 in Cologne we set up an instance on SQL Server. You can do so yourself as well to follow along. See [Getting started](http://docs.simplifier.net/vonk/start.html) on how to do that.

### Database structure

The SQL Table structure that Vonk uses contains:
- the raw resource, serialized as JSON, allowing us to use the SQL Server JSON operations (SQL Server >= 2016);
- indexes for all (types of) searchparameters, allowing us to use pure SQL provided the values of interest are indexed as searchparameters. If they are not, see [Using Custom Search Parameters](http://docs.simplifier.net/vonk/features/customsearchparameters.html) on how to add your own searchparameters.

### Data

We used Synthea data. It is distributed as 12 zipped files. We imported the first 1000 bundles / patient records from set nr. 1.

### Queries

We tried to execute queries analog to the ones against AidBox / postgresql, for good comparison. See the [Jupiter file](http://uhn-jupyter.health-samurai.io/notebooks/postgres_examples.ipynb) for the source of those.

To follow along, open SQL Server Management Studio or some other query tool and connect it to your Vonk database (not the administration database).

#### Select a patient resource
```sql
    select top 1 e.ResourceJson from vonk.entry e where e.Type = 'Patient'
```

#### See patients names in plain text
```sql

select top 10 e.EntryId,
	coalesce(g.LongString, g.ShortString) + ' ' 
	+ coalesce(f.LongString, f.ShortString) as name 

from vonk.entry e 
join vonk.str g on (g.EntryId = e.EntryId)
join vonk.str f on (f.EntryId = e.EntryId)
where e.Type = 'Patient'
and g.Name = 'given'
and f.Name = 'family'
```

or directly in the json
```sql
select top 10 e.EntryId, 
	JSON_VALUE(e.ResourceJson, N'$.name[0].given[0]')
	+ ' ' +
	JSON_VALUE(e.ResourceJson, N'$.name[0].family')
	 as name
from vonk.entry e
where e.Type = 'Patient'
```

#### search by prefix in name
```sql
select top 10 e.EntryId,
	coalesce(g.LongString, g.ShortString) + ' ' 
	+ coalesce(f.LongString, f.ShortString) as name 

from vonk.entry e 
join vonk.str g on (g.EntryId = e.EntryId)
join vonk.str f on (f.EntryId = e.EntryId)
where e.Type = 'Patient'
and g.Name = 'given'
and f.Name = 'family'
and f.ShortString like 'Abbott%'
```

or directly in the json
```sql
select top 10 e.EntryId, 
	JSON_VALUE(e.ResourceJson, N'$.name[0].given[0]')
	+ ' ' +
	JSON_VALUE(e.ResourceJson, N'$.name[0].family')
	 as name
from vonk.entry e
where e.Type = 'Patient'
and JSON_VALUE(e.ResourceJson, N'$.name[0].family') like 'Abbott%'
```

#### search by birth date
```sql
select top 10 e.EntryId,
	JSON_VALUE(e.ResourceJson, N'$.name[0].given[0]')
	+ ' ' +
	JSON_VALUE(e.ResourceJson, N'$.name[0].family')
	 as name,
	JSON_VALUE(e.ResourceJson, N'$.birthDate') as birthdate
from vonk.entry e
join vonk.dt d on (e.EntryId = d.EntryId)
where e.Type = 'Patient'
and d.[Start] >= '1970-01-01'
and d.[End] <= '1975-01-01'
and d.[Name] = 'birthdate'
order by e.EntryId
```

directly in json
```sql
select top 10 e.EntryId,
	JSON_VALUE(e.ResourceJson, N'$.name[0].given[0]')
	+ ' ' +
	JSON_VALUE(e.ResourceJson, N'$.name[0].family')
	 as name,
	JSON_VALUE(e.ResourceJson, N'$.birthDate') as birthdate
from vonk.entry e
where 
	CONVERT(date, JSON_VALUE(e.ResourceJson, N'$.birthDate'), 120) between '1970-01-01' and '1975-01-01'
order by e.EntryId
``` 

#### get all procedures for an encounter
```sql
select top 10 
	e.EntryId as [encounterId], p.ResourceJson as [procedure]
from vonk.entry p
join vonk.ref r on (p.EntryId = r.EntryId)
join vonk.entry e on (r.RelativeReference = e.Reference)
where e.Type = 'Encounter'
and p.Type = 'Procedure'
and r.Name = 'encounter'
```

directly in json
```sql
select top 10 
	p.ResourceJson as [procedure]
from vonk.entry p
join vonk.ref r on (p.EntryId = r.EntryId)
where p.Type = 'Procedure'
and r.Name = 'encounter'
```

#### collect patients age statistics
```sql
WITH ages (age, id) 
AS
(
	select 
		DATEDIFF(year, d.[Start], GETDATE()) as age,
		e.EntryId as id
	from vonk.entry e
	join  vonk.dt as d on e.EntryId = d.EntryId
	where e.Type = 'Patient'
)
select age, count(id) as number
from ages
group by age
order by age
```

