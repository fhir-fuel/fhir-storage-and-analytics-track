## Google BigQuery using FHIR Proto Schema

### Summary

[BigQuery](https://cloud.google.com/bigquery/) is Google's serverless, highly
scalable, low cost enterprise data warehouse designed to make all your data
analysts productive.

There is a [protocol buffer representation of
FHIR](https://github.com/google/fhir), which can be used as a schema for
hosting FHIR data in BigQuery. In this project, we demonstrate how synthetic
FHIR resources can be imported to Google BigQuery using the proto format, and
how to run search and analysis using the imported data.

### Bootstrap

The dataset we use for this project is the Synthea dataset provided for this
connectathon at https://storage.googleapis.com/fhir-storage/synthea.tar.gz.

To run the example code in this project, you need to follow instructions at
https://docs.bazel.build/versions/master/install.html to install `bazel`.
Then, download and compile the FHIR proto source code.

```shell
git clone https://github.com/google/fhir
bazel test //...
```

In https://github.com/google/fhir/tree/master/examples/bigquery, there is an
example for importing FHIR data into Google BigQuery. Since we already have the
dataset, there is no need to run step `01-get-synthea.sh`, but instead we can
directly start from proto parsing. You can run `02-parse-into-protobuf.sh`
directly if your FHIR JSON files are located at `synthea/output/fhir/`, or run

```shell
bazel-bin/java/SplitBundle /path/to/json
```

for the data location you specify.

Once the data is converted into ndjson files, you can then run `03-upload-to-bq.sh` followed
by `04-run-queries.sh`, to upload the data to BigQuery and run all analysis queries in this
directory, respectively.

Note: BigQuery tries to detect the table schema based on the first 100 rows of the `ndjson`
files. It may fail if the rest of the file contains a row that does not match the determined
schema.

### Store and Retrieve FHIR resource

To show a row of a table, one can run a query, e.g.

```sql
SELECT * FROM synthea.Patient LIMIT 1;
```

However, the "Preview" tab of the table is the preferred way of previewing data without
incurring any cost: https://cloud.google.com/bigquery/docs/best-practices-costs#preview-data

### Search by resource elements

How to search specific resourceType by specific element

### Related resources

How to represent references between resources

How to search and retrieve related resources

### Analytic

More complicated queries with aggregation etc
