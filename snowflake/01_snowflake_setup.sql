-- =========================================================
-- 1. CREATE COMPUTE WAREHOUSE
-- =========================================================

CREATE WAREHOUSE IF NOT EXISTS BANKING_WH
    WITH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;


-- =========================================================
-- 2. CREATE DATABASE
-- =========================================================

CREATE DATABASE IF NOT EXISTS BANKING_DB;


-- =========================================================
-- 3. CREATE SCHEMAS
-- =========================================================

CREATE SCHEMA IF NOT EXISTS BANKING_DB.RAW;

CREATE SCHEMA IF NOT EXISTS BANKING_DB.STAGING;

CREATE SCHEMA IF NOT EXISTS BANKING_DB.ANALYTICS;


-- =========================================================
-- 4. SET CONTEXT
-- =========================================================

USE WAREHOUSE BANKING_WH;

USE DATABASE BANKING_DB;

USE SCHEMA RAW;