
```
mc cp synthea.gz uhn/fhir-storage/synthea.gz

pg_dump synthea | gzip > synthea.gz

gunzip -c synthea.gz | psql synthea
cat synthea.gz | gunzip | psql synthea

curl https://storage.googleapis.com/fhir-storage/synthea.gz | gunzip | psql synthea
```
