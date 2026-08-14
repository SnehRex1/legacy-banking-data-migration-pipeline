-- ============================================================
-- 06_snowflake_create_tables.sql
-- Create Snowflake target table for banking data
-- ============================================================


-- Set database and schema context

USE DATABASE BANKING_DB;

USE SCHEMA PUBLIC;


-- Verify current database and schema

SELECT CURRENT_DATABASE(), CURRENT_SCHEMA();



-- ============================================================
-- Create target table
-- Schema is based on the Parquet data inferred in Step 05
-- ============================================================

CREATE OR REPLACE TABLE BANKING_TRANSACTIONS (
    TRANSACTION_ID      VARCHAR,
    ACCOUNT_ID          VARCHAR,
    TRANSACTION_DATE    DATE,
    TRANSACTION_TYPE    VARCHAR,
    AMOUNT              FLOAT,
    TRANSACTION_YEAR    NUMBER,
    TRANSACTION_MONTH   NUMBER,
    CUSTOMER_ID         VARCHAR,
    ACCOUNT_TYPE        VARCHAR,
    BALANCE             FLOAT,
    STATUS              VARCHAR,
    CUSTOMER_NAME       VARCHAR,
    CITY                VARCHAR,
    SEGMENT             VARCHAR
);



-- ============================================================
-- Verify target table
-- ============================================================

SHOW TABLES IN SCHEMA BANKING_DB.PUBLIC;



-- ============================================================
-- Inspect table structure
-- ============================================================

DESC TABLE BANKING_TRANSACTIONS;