-- ============================================================
-- 05_snowflake_load_data.sql
-- Inspect Parquet schema and load S3 data into Snowflake RAW
-- ============================================================


-- ============================================================
-- Set database and schema context
-- ============================================================

USE DATABASE BANKING_DB;

USE SCHEMA PUBLIC;


-- ============================================================
-- Verify current database and schema
-- ============================================================

SELECT
    CURRENT_DATABASE(),
    CURRENT_SCHEMA();


-- ============================================================
-- Verify existing tables in the target schema
-- ============================================================

SHOW TABLES IN SCHEMA BANKING_DB.PUBLIC;


-- ============================================================
-- Infer schema from Parquet files in the external stage
-- ============================================================

SELECT *
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@LEGACY_BANKING_S3_STAGE',
        FILE_FORMAT => 'BANKING_PARQUET_FORMAT'
    )
);