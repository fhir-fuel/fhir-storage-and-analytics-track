# FHIR Storage, Query & Analytics

Submitting WG/Project/Implementer Group - 
No such group, should we form it?


## Justification 

More and more developers about to start design storage for FHIR data.
We hope this group/track will share experience about FHIR storage implementation,
as well as analytics on FHIR datasets.


## Scenarios

### Scenario 1: FHIR search
* Design or take an existing database schema to store Patient, Encounter & Practitioner resources
  * relational (consider schema generation)
  * document oriented 
     * postgresql jsonb
     * mongodb
     * big query
  * tripple store (datomic, EAV)
  * xml database (?)
* Load sample data
* Implement FHIR search for 
  * Patient by name, address
  * Encounter by date and location/practitioner
  * Encounter _include patient/practitioner
* On fly convertion to FHIR if format is different

### Scenario 2: Advanced FHIR search

* Design or take an existing database schema to store Patient & Observation
* Implement search by quantity with respect to system and units

### Scenario 3: Complex Queries / CQL

* Implement CQL to SQL (or other query lang) translation (automatic or manual)
* Another analytic queries???


### Scenario 4: Analytical databases replication

* Get `transaction log` / history of all CRUD/transaction operations from kafka topic
* Transform and load into analytical databases
  * Click House
  * Elastic Search
  * Vertica
  * Relational databases (MS SQL, Oracle, Postgresql, Mysql)
* Run analytical queries


## Assets

* we will provide you with test datasets 
* jupyter environment with examples (will be used for demo after track)
* access to existing databases
  * fhirbase
  * Biq Query
  * aidbox
  * HAPI db?
  * ....

## Outcomes

* make you familiar with different approaches
* report/guidelines for implementation of FHIR database
* discuss your questions in a group :)


## Questions to be answered

* How to store FHIR data?
* What is database schema design?
* Which databases can be used?
* What i have to do to be part of it?
* How to approach FHIR search?



## Databases

### Relational

* PostgreSQL
* Big Query

### Document databases

* MongoDB

### Analytical

* ElasitcSearch
* ClickHouse
* Vertica
* Spark / Hadoop?

### Integration bus

* Kafka


## Participants

* [Health Samurai](http://health-samur.ai)
