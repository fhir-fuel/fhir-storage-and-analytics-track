# FHIR Storage, Query & Analytics

Submitting WG/Project/Implementer Group - 
No such group, should we form it?

See also [FHIR wiki](http://wiki.hl7.org/index.php?title=201805_FHIR_Storage_and_Analytics#Track_Overview)

## Justification 

More and more developers about to start design storage for FHIR data.
We hope this group/track will share experience about FHIR storage implementation,
as well as analytics on FHIR datasets.

## Roles

* Data Storage - software or server which has API to read/write FHIR
  resources (Data Storage don't have to conform FHIR REST API);
* Data Importer - software that interacts with Data Storage API to
  perform fast imports of large amounts of FHIR resources;
* User - a person who interacts with Data Importer program.

## Scenarios

### Scenario 1: FHIR search
* Design or take an existing database schema to store Patient, Encounter & Practitioner resources
  * relational (consider schema generation)
  * document oriented 
     * postgresql jsonb
     * mongodb
     * big query
  * Graph databases
     * neo4j
  * tripple store (datomic, EAV)
  * xml database (?)
* Load sample data
* Implement FHIR search for 
  * Patient by name, address
  * Encounter by date and location/practitioner
  * Encounter include patient/practitioner
  * Encounter chained params
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

### Scenario 5: Graphql implementaton

* prototype efficient graphql => sql transpilation

### Scenario 6: Import FHIR resources from local file

1. User prepares or somewhere downloads a [NDJSON](http://ndjson.org/)
   file containing FHIR resources. That file can be optionally
   GZIPed. File can contain resources of different kinds (like FHIR bundle).

2. User runs Data Importer to upload FHIR resources from that file
   into Data Storage. Optionally, Data Importer or Data Storage can
   perform validations to check resource content for FHIR conformance.

3. User checks that FHIR data was successfuly imported with Data
   Storage API. For instance, in PostgreSQL one can invoke:

   > SELECT COUNT(*) FROM patient;

   To check how much Patient resources was imported.

### Scenario 7: Bulk Data API client

1. User runs Data Importer providing [Bulk Data
   API](https://github.com/smart-on-fhir/fhir-bulk-data-docs) endpoint
   as an argument.

2. Data Importer acts as Bulk Data API client and downloads data
   returned by server.

3. Downloaded data is being imported to Data Storage by Data Importer.

4. User checks that FHIR data was successfuly imported. For instance,
   in PostgreSQL user can invoke:

   > SELECT COUNT(*) FROM patient;

   to check how much Patient resources was imported.

### Discussion

fhirpath implementation/subset for databases
Current limitations of the FHIR Search API?


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
