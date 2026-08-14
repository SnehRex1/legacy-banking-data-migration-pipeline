-- ============================================================
-- 04_snowflake_external_stage.sql
-- Create Snowflake external stage for S3 Parquet data
-- ============================================================

USE DATABASE BANKING_DB;

SELECT CURRENT_DATABASE(), CURRENT_SCHEMA();

-- Create external stage

CREATE OR REPLACE STAGE LEGACY_BANKING_S3_STAGE
    URL = 's3://legacy-banking-data/processed/banking_integrated/'
    STORAGE_INTEGRATION = LEGACY_BANKING_S3_INT;


-- Verify stage
SHOW STAGES;

-- Test S3 access

LIST @LEGACY_BANKING_S3_STAGE;