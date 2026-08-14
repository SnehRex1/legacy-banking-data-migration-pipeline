# Legacy Banking Data Migration & Analytics Pipeline

> **Enterprise-style legacy-to-modern cloud data migration project using
> Hadoop/Hive, PySpark, Amazon S3, AWS IAM, and Snowflake.**

This project simulates a real-world banking data engineering pipeline in
which legacy banking data is profiled, validated, quarantined, cleaned,
transformed, converted to Parquet, moved through an AWS S3 data lake,
and loaded into Snowflake for analytics.

The project demonstrates an end-to-end **batch data engineering
workflow** with an emphasis on data quality, auditability, scalable
transformation, cloud storage, warehouse loading, and business
analytics.

------------------------------------------------------------------------

## Architecture


<img width="2780" height="1536" alt="image" src="https://github.com/user-attachments/assets/ecd2430f-06a4-4bfc-9b0d-3b759b57a572" />



### High-level flow

``` text
Legacy CSV Data
      |
      v
Hadoop / Hive
  |       |
  |       +--> Data Quality Checks
  |                 |
  |                 +--> Quarantine Bad Records
  |
  +--> Clean Data
          |
          v
      Hive Partitioning
          |
          v
        PySpark
   (Join / Transform / DQ)
          |
          v
      Snappy Parquet
          |
          v
       Amazon S3
          |
          v
     Snowflake Stage
          |
          v
       COPY INTO
          |
          v
 Snowflake Analytical Tables
          |
          v
 Business SQL / Analytics
```

------------------------------------------------------------------------

## Project Objectives

-   Simulate migration from a **legacy Hadoop/Hive environment to a
    modern cloud data warehouse**.
-   Preserve raw source data for traceability and audit purposes.
-   Identify and quarantine invalid banking transactions.
-   Apply data-quality and referential-integrity checks.
-   Transform and join customer, account, and transaction datasets using
    PySpark.
-   Store processed data as compressed **Parquet** files.
-   Use Amazon S3 as the cloud data lake layer.
-   Secure S3 access using an **AWS IAM role** instead of hardcoded
    credentials.
-   Load processed data into Snowflake using an external stage and
    `COPY INTO`.
-   Validate row counts and data consistency between Hive and Snowflake.
-   Run business-oriented SQL analytics on the migrated banking data.

------------------------------------------------------------------------

## Technology Stack

  Layer                        Technology
  ---------------------------- ----------------------------
  Source Data                  CSV
  Legacy Processing            Hadoop / Hive
  Data Quality                 Hive SQL
  Distributed Processing       PySpark
  Programming                  Python
  Cloud Storage                Amazon S3
  Cloud Security               AWS IAM
  File Format                  Snappy Parquet
  Cloud Data Warehouse         Snowflake
  Transformation / Analytics   SQL
  Version Control              Git / GitHub
  Local Environment            Docker / Hive Docker setup

------------------------------------------------------------------------

## Repository Structure

``` text
legacy-banking-data-migration/
│
├── architecture diagram/
│   └── architecture.png
│
├── data/
│   └── *.csv
│
├── docs/
│   └── project documentation
│
├── hive/
│   ├── 01_create_tables.sql
│   ├── 02_load_raw_data.sql
│   ├── 03_data_quality.sql
│   ├── 04_quarantine.sql
│   ├── 05_clean_data.sql
│   └── 06_partitioning.sql
│
├── hive_warehouse/
│   └── Hive warehouse data
│
├── hive-docker-data/
│   └── Local Hive/Docker runtime data
│
├── pyspark/
│   ├── dq_validation.py
│   ├── join_data.py
│   ├── read_clean.py
│   ├── read_hive.py
│   ├── test_spark.py
│   ├── transform_data.py
│   └── write_parquet.py
│
├── processed_data/
│   └── banking_integrated/
│       └── *.parquet
│
├── snowflake/
│   ├── 01_snowflake_setup.sql
│   ├── 02_verify_setup.sql
│   ├── 03_snowflake_s3_integration.sql
│   ├── 04_snowflake_external_stage.sql
│   ├── 05_snowflake_load_data.sql
│   ├── 06_snowflake_create_tables.sql
│   ├── 07_snowflake_copy_into.sql
│   ├── 08_snowflake_validate_data.sql
│   ├── 09_snowflake_transformations.sql
│   └── 10_snowflake_business_queries.sql
│
├── screenshots/
│   └── validation and execution screenshots
│
├── make_dirty_legacy_data.py
├── setup_hive_docker.sh
├── hive-init.sql
├── .gitignore
└── README.md
```

> **Note:** Runtime-generated folders such as Hive warehouse data,
> Derby/metastore files, logs, and Docker state should not be committed
> to GitHub. The included `.gitignore` excludes these artifacts.

------------------------------------------------------------------------

# 1. Legacy Banking Data

The project starts with simulated legacy banking data containing
entities such as:

-   Customers
-   Accounts
-   Transactions

The source data intentionally contains data-quality problems to
reproduce realistic migration conditions.

Examples include:

-   Duplicate transaction IDs
-   Missing IDs
-   Invalid transaction types
-   Invalid account/customer references
-   Missing values
-   Invalid banking relationships

The script:

``` text
make_dirty_legacy_data.py
```

can be used to generate or introduce dirty records for testing the
data-quality pipeline.

------------------------------------------------------------------------

# 2. Hive / Legacy Data Layer

The Hive layer represents the **legacy on-premise processing
environment**.

### Create tables

``` bash
hive -f hive/01_create_tables.sql
```

### Load raw data

``` bash
hive -f hive/02_load_raw_data.sql
```

### Run data-quality profiling

``` bash
hive -f hive/03_data_quality.sql
```

The profiling stage checks conditions such as:

-   Duplicate records
-   Null / missing identifiers
-   Valid transaction types
-   Referential integrity
-   Record counts
-   Data completeness

------------------------------------------------------------------------

# 3. Data Quarantine

Invalid records are not simply deleted.

Instead, they are moved into a quarantine layer containing information
such as:

``` text
transaction
quarantine_reason
```

This provides an auditable rejection mechanism.

Example rejection reasons:

``` text
Missing transaction ID
Duplicate transaction ID
Invalid transaction type
Missing account reference
Invalid customer reference
```

Run:

``` bash
hive -f hive/04_quarantine.sql
```

### Why quarantine?

In an enterprise banking environment, deleting bad records without
retaining evidence is undesirable because rejected records may need to
be:

-   Audited
-   Investigated
-   Corrected
-   Reprocessed
-   Reconciled with the source system

------------------------------------------------------------------------

# 4. Clean Data Layer

After quarantine, valid records are written to clean tables.

``` bash
hive -f hive/05_clean_data.sql
```

The clean layer separates trusted records from rejected records while
preserving the original source data.

------------------------------------------------------------------------

# 5. Hive Partitioning

The cleaned transaction data is partitioned by date-related fields.

``` bash
hive -f hive/06_partitioning.sql
```

Conceptually:

``` text
transactions_clean/
├── year=2025/
│   ├── month=01/
│   └── month=02/
└── year=2026/
    ├── month=01/
    └── month=02/
```

Partitioning improves query performance by allowing Hive to scan only
relevant partitions for date-filtered queries.

------------------------------------------------------------------------

# 6. PySpark Processing

PySpark is used as the distributed transformation layer after the Hive
data-quality stage.

The main scripts are:

### `read_hive.py`

Reads the Hive/processed datasets into Spark.

### `read_clean.py`

Reads validated clean data for downstream processing.

### `dq_validation.py`

Performs additional data-quality validation using Spark.

### `join_data.py`

Joins relevant banking entities such as:

``` text
Customers
    +
Accounts
    +
Transactions
```

### `transform_data.py`

Creates analytical fields and applies business transformations.

### `write_parquet.py`

Writes the integrated dataset as compressed Parquet.

Typical output:

``` text
processed_data/
└── banking_integrated/
    └── part-*.parquet
```

------------------------------------------------------------------------

# 7. Parquet Data Layer

The transformed dataset is stored in **Parquet** format with Snappy
compression.

Benefits:

-   Columnar storage
-   Compression
-   Efficient analytical reads
-   Schema preservation
-   Better performance than raw CSV for analytical workloads
-   Suitable for cloud data-lake processing

------------------------------------------------------------------------

# 8. AWS S3 Data Lake

Amazon S3 represents the cloud data lake layer.

A logical structure is:

``` text
s3://legacy-banking-data/

├── processed/
│
├── banking_integrated/
│
└── transactions/
```

The processed Parquet files generated by PySpark can be uploaded to the
S3 bucket.

Example:

``` bash
aws s3 cp processed_data/banking_integrated/ \
    s3://legacy-banking-data/processed/banking_integrated/ \
    --recursive
```

Replace the bucket name and paths with your own AWS resources.

------------------------------------------------------------------------

# 9. AWS IAM

The Snowflake-to-S3 integration uses an AWS IAM role/policy model.

The project avoids putting AWS access keys or secret keys inside SQL
scripts or source code.

**Never commit credentials to GitHub.**

Examples of secrets that must not be committed:

``` text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
SNOWFLAKE_PASSWORD
PRIVATE_KEY
ACCOUNT_PASSWORD
```

------------------------------------------------------------------------

# 10. Snowflake Integration

The Snowflake workflow is divided into multiple SQL scripts so that each
stage can be executed and validated independently.

### Setup

``` bash
snowflake/01_snowflake_setup.sql
```

Creates the required Snowflake database, schemas, warehouses, and
supporting objects.

### Verify setup

``` bash
snowflake/02_verify_setup.sql
```

Validates that the Snowflake environment has been created correctly.

### S3 integration

``` bash
snowflake/03_snowflake_s3_integration.sql
```

Creates the required cloud-storage integration / IAM configuration.

### External stage

``` bash
snowflake/04_snowflake_external_stage.sql
```

Creates a Snowflake external stage pointing to S3.

Conceptually:

``` text
Snowflake
    |
    v
External Stage
    |
    v
Amazon S3
```

------------------------------------------------------------------------

# 11. Loading Data into Snowflake

The Parquet data is loaded using:

``` sql
COPY INTO
```

The corresponding script is:

``` text
snowflake/07_snowflake_copy_into.sql
```

The general flow is:

``` text
S3 Parquet
     |
     v
Snowflake External Stage
     |
     v
COPY INTO
     |
     v
Snowflake Table
```

------------------------------------------------------------------------

# 12. Snowflake Validation

After loading, the data is validated using:

``` text
snowflake/08_snowflake_validate_data.sql
```

Validation includes:

-   Row counts
-   Null checks
-   Duplicate checks
-   Data type validation
-   Migration reconciliation
-   Source-to-target consistency

The objective is to confirm that:

``` text
Hive Clean Data Count
          =
Snowflake Loaded Data Count
```

where applicable.

------------------------------------------------------------------------

# 13. Snowflake Transformations

Additional warehouse-level transformations are contained in:

``` text
snowflake/09_snowflake_transformations.sql
```

This layer prepares data for analytical consumption.

------------------------------------------------------------------------

# 14. Business Analytics

Business-oriented queries are contained in:

``` text
snowflake/10_snowflake_business_queries.sql
```

Example analytical use cases include:

-   Transaction summaries
-   Customer analysis
-   Transaction direction analysis
-   Amount categories
-   Largest transactions
-   High-value transactions
-   Transaction counts
-   Business segmentation

Example conceptual classification:

``` text
Transaction Amount
       |
       +--> Low
       |
       +--> Medium
       |
       +--> High
```

These queries demonstrate how the migrated data can support business
reporting and analytics.

------------------------------------------------------------------------

# Data Quality Framework

The project follows a simple but realistic data-quality strategy:

``` text
Raw Data
   |
   v
Profiling
   |
   +---- Invalid ----> Quarantine
   |
   v
Valid Data
   |
   v
Clean Layer
   |
   v
Transformation
   |
   v
Warehouse
```

Important checks include:

### Completeness

Checks whether required fields are populated.

### Uniqueness

Detects duplicate identifiers such as transaction IDs.

### Validity

Checks whether values belong to accepted domains.

Example:

``` text
transaction_type IN
('Deposit', 'Withdrawal', 'Transfer')
```

### Referential Integrity

Checks relationships such as:

``` text
Transaction
    -> Account
    -> Customer
```

------------------------------------------------------------------------

# Reconciliation

A key migration principle is **source-to-target reconciliation**.

Example:

``` sql
SELECT COUNT(*)
FROM source_clean_transactions;
```

versus:

``` sql
SELECT COUNT(*)
FROM snowflake_transactions;
```

Counts and important business metrics should be compared after each
migration stage.

This helps identify:

-   Missing records
-   Duplicate records
-   Failed loads
-   Transformation errors
-   Filtering mistakes

------------------------------------------------------------------------

# Running the Project Locally

## Prerequisites

Install or configure:

-   Docker
-   Hive
-   Hadoop components required by the local Hive setup
-   Python 3
-   PySpark
-   AWS CLI
-   AWS account
-   Snowflake account
-   Git

Check Python:

``` bash
python --version
```

Check Docker:

``` bash
docker --version
```

Check AWS CLI:

``` bash
aws --version
```

------------------------------------------------------------------------

## Start the Hive Environment

The repository contains:

``` text
setup_hive_docker.sh
```

Run:

``` bash
bash setup_hive_docker.sh
```

Follow the script output to start the local Hive environment.

------------------------------------------------------------------------

# Recommended Execution Order

Run the pipeline in this order:

``` text
1. Generate / prepare legacy data
        ↓
2. Start Hive / Docker
        ↓
3. Create Hive tables
        ↓
4. Load raw data
        ↓
5. Run data-quality profiling
        ↓
6. Quarantine invalid records
        ↓
7. Create clean tables
        ↓
8. Partition clean data
        ↓
9. Read clean data with PySpark
        ↓
10. Validate and join datasets
        ↓
11. Transform data
        ↓
12. Write Snappy Parquet
        ↓
13. Upload Parquet to S3
        ↓
14. Configure Snowflake integration
        ↓
15. Create Snowflake external stage
        ↓
16. COPY INTO Snowflake
        ↓
17. Validate source vs target
        ↓
18. Run analytical transformations
        ↓
19. Run business SQL queries
```

------------------------------------------------------------------------

# Security Notes

This repository is intended for demonstration and portfolio purposes.

### Do not commit:

``` text
.env
AWS credentials
Snowflake passwords
Private keys
Cloud account credentials
Terraform state containing secrets
Local database files
Docker credentials
```

Use environment variables, AWS IAM roles, Snowflake secrets management,
or your CI/CD platform's secret store for real deployments.

------------------------------------------------------------------------

# GitHub Upload Checklist

Before pushing the project:

``` bash
git status
```

Verify that credentials and runtime files are not listed.

Then:

``` bash
git add .
git commit -m "Initial commit: legacy banking data migration pipeline"
git push -u origin main
```

If the repository does not yet have a remote:

``` bash
git remote add origin <YOUR_GITHUB_REPOSITORY_URL>
git branch -M main
git push -u origin main
```

------------------------------------------------------------------------

# Important GitHub Cleanup

Do **not** upload:

``` text
metastore_db/
metastore_db_backup/
hive-docker-data/
logs/
derby.log
*.log
*.db
__pycache__/
.venv/
.env
AWS credentials
Snowflake credentials
large generated warehouse files
```

The `.gitignore` included with this project handles most of these
automatically.

------------------------------------------------------------------------

# Project Highlights

This project demonstrates practical Data Engineering concepts:

-   Legacy system migration
-   Hive SQL
-   Hadoop ecosystem
-   Data profiling
-   Data-quality validation
-   Data quarantine
-   Clean data layers
-   Hive partitioning
-   PySpark ETL
-   Distributed joins
-   Data transformation
-   Parquet
-   Snappy compression
-   AWS S3
-   AWS IAM
-   Snowflake
-   External stages
-   `COPY INTO`
-   Data reconciliation
-   SQL analytics
-   Git/GitHub
-   Enterprise-style layered architecture

------------------------------------------------------------------------

# Interview Discussion Points

This project can be used to discuss:

### Why Hive?

Hive represents the legacy batch-processing environment and demonstrates
SQL-based processing over large datasets.

### Why PySpark after Hive?

Hive handles legacy data preparation and quality checks, while PySpark
provides flexible distributed transformations and joins.

### Why Parquet?

Parquet is columnar, compressed, schema-aware, and well suited to
analytical workloads.

### Why S3?

S3 provides durable, scalable, low-cost object storage and decouples the
data lake from the processing/warehouse layer.

### Why Snowflake?

Snowflake provides scalable cloud data warehousing and separates storage
from compute.

### Why quarantine instead of deleting invalid data?

Banking data requires traceability and auditability. Quarantine
preserves rejected records and their reasons.

### Why IAM roles?

IAM-based access avoids embedding long-lived AWS credentials in
application code or SQL scripts.

### Why reconciliation?

Migration is not complete simply because a load succeeds. Source and
target data must be validated for completeness and correctness.

------------------------------------------------------------------------

# Disclaimer

This is a **simulated banking data migration project for educational and
portfolio purposes**. The datasets are synthetic and should not contain
real customer or financial information.

------------------------------------------------------------------------

## Author

**Sneh Gupta**

B.Tech -- Computer Science & Engineering

GitHub: `https://github.com/SnehRex1`

LinkedIn: `https://linkedin.com/in/sneh-gupta-755175167`
