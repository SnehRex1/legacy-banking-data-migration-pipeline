-- ============================================================
-- 09_snowflake_transformations.sql
-- Create analytics-ready banking transaction data
-- ============================================================


-- Set database and schema context

USE DATABASE BANKING_DB;

USE SCHEMA PUBLIC;


-- ============================================================
-- Create transformed transaction table
-- ============================================================

CREATE OR REPLACE TABLE BANKING_TRANSACTIONS_TRANSFORMED AS

SELECT
    TRANSACTION_ID,
    ACCOUNT_ID,
    CUSTOMER_ID,
    CUSTOMER_NAME,

    TRANSACTION_DATE,
    TRANSACTION_TYPE,
    AMOUNT,

    TRANSACTION_YEAR,
    TRANSACTION_MONTH,

    -- Date dimensions
    DAY(TRANSACTION_DATE) AS TRANSACTION_DAY,
    MONTHNAME(TRANSACTION_DATE) AS TRANSACTION_MONTH_NAME,
    QUARTER(TRANSACTION_DATE) AS TRANSACTION_QUARTER,

    -- Transaction amount category
    CASE
        WHEN AMOUNT < 10000 THEN 'LOW'
        WHEN AMOUNT < 100000 THEN 'MEDIUM'
        ELSE 'HIGH'
    END AS AMOUNT_CATEGORY,

    -- Transaction direction
    CASE
        WHEN TRANSACTION_TYPE = 'Deposit' THEN 'CREDIT'
        WHEN TRANSACTION_TYPE = 'Withdrawal' THEN 'DEBIT'
        WHEN TRANSACTION_TYPE = 'Transfer' THEN 'TRANSFER'
        ELSE 'UNKNOWN'
    END AS TRANSACTION_DIRECTION,

    -- Net transaction amount
    CASE
        WHEN TRANSACTION_TYPE = 'Deposit' THEN AMOUNT
        WHEN TRANSACTION_TYPE = 'Withdrawal' THEN -AMOUNT
        ELSE 0
    END AS NET_TRANSACTION_AMOUNT

FROM BANKING_TRANSACTIONS;


-- ============================================================
-- Verify transformed table
-- ============================================================

SELECT
    COUNT(*) AS TOTAL_ROWS
FROM BANKING_TRANSACTIONS_TRANSFORMED;


-- ============================================================
-- Preview transformed data
-- ============================================================

SELECT *
FROM BANKING_TRANSACTIONS_TRANSFORMED
LIMIT 10;


-- ============================================================
-- Verify transaction direction
-- ============================================================

SELECT
    TRANSACTION_DIRECTION,
    COUNT(*) AS TRANSACTION_COUNT,
    SUM(AMOUNT) AS TOTAL_AMOUNT
FROM BANKING_TRANSACTIONS_TRANSFORMED
GROUP BY TRANSACTION_DIRECTION
ORDER BY TRANSACTION_COUNT DESC;


-- ============================================================
-- Verify amount categories
-- ============================================================

SELECT
    AMOUNT_CATEGORY,
    COUNT(*) AS TRANSACTION_COUNT,
    SUM(AMOUNT) AS TOTAL_AMOUNT
FROM BANKING_TRANSACTIONS_TRANSFORMED
GROUP BY AMOUNT_CATEGORY
ORDER BY TRANSACTION_COUNT DESC;