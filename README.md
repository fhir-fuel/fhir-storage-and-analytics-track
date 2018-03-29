# FHIR Storage & Analytics

Submitting WG/Project/Implementer Group
Health Samurai

## Justification

Choosing a storage for your FHIR implementation is like choosing a set of tradeoffs that will affect development process greatly. We want to share our experience of implementing FHIR services using relational databases and jsonb with FHIR Search API as an example. But sometimes fhir search is not enough - this is the case with reports, sophisticated business logic and analytics. For some cases complex SQL queries will suffice, but often the need to use special analytic tooling arises. We will show how one can implement integration of FHIR server and analytic database of choice.

## FHIR transaction log

as a source of data for FHIR server replication for analytical databases

## Databases

* PostgreSQL
* Biq Query
* MongoDB
* ElasitcSearch
* ClickHouse
* ????

## Integration bus

* Kafka
