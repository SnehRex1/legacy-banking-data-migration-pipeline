-- ============================================================
-- LEGACY BANKING DATA MIGRATION
-- HIVE - CREATE DATABASE AND TABLES
-- ============================================================

CREATE DATABASE IF NOT EXISTS banking_legacy;

USE banking_legacy;


-- ============================================================
-- 1. CUSTOMERS RAW
-- ============================================================

DROP TABLE IF EXISTS customers_raw;

CREATE TABLE customers_raw (
    customer_id   STRING,
    customer_name STRING,
    city          STRING,
    segment       STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES (
    'skip.header.line.count' = '1'
);


-- ============================================================
-- 2. ACCOUNTS RAW
-- ============================================================

DROP TABLE IF EXISTS accounts_raw;

CREATE TABLE accounts_raw (
    account_id   STRING,
    customer_id  STRING,
    account_type STRING,
    balance      STRING,
    status       STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES (
    'skip.header.line.count' = '1'
);


-- ============================================================
-- 3. TRANSACTIONS RAW
-- ============================================================

DROP TABLE IF EXISTS transactions_raw;

CREATE TABLE transactions_raw (
    transaction_id   STRING,
    account_id       STRING,
    transaction_date STRING,
    transaction_type STRING,
    amount           STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES (
    'skip.header.line.count' = '1'
);


-- ============================================================
-- 4. SHOW CREATED TABLES
-- ============================================================

SHOW TABLES;