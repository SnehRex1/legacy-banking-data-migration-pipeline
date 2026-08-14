-- ============================================================
-- 07_snowflake_copy_into.sql
-- Load banking Parquet data from S3 into Snowflake table
-- ============================================================


-- Set database and schema context

USE DATABASE BANKING_DB;

USE SCHEMA PUBLIC;


-- Verify current database and schema

SELECT CURRENT_DATABASE(), CURRENT_SCHEMA();



-- ============================================================
-- Load data from external stage
-- ============================================================

COPY INTO BANKING_TRANSACTIONS
FROM @LEGACY_BANKING_S3_STAGE
FILE_FORMAT = (FORMAT_NAME = 'BANKING_PARQUET_FORMAT')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;



-- ============================================================
-- Verify COPY INTO result
-- ============================================================

-- Check the load status, rows loaded, and any errors
-- returned by the COPY operation.



-- ============================================================
-- Check loaded row count
-- ============================================================

SELECT COUNT(*) AS TOTAL_ROWS
FROM BANKING_TRANSACTIONS;



-- ============================================================
-- Preview loaded data
-- ============================================================

SELECT *
FROM BANKING_TRANSACTIONS
LIMIT 10;