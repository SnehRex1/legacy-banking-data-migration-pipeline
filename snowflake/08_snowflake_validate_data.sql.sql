-- ============================================================
-- 08_snowflake_validate_data.sql
-- Validate data loaded into Snowflake
-- ============================================================


-- Set database and schema context

USE DATABASE BANKING_DB;

USE SCHEMA PUBLIC;


-- ============================================================
-- Verify current database and schema
-- ============================================================

SELECT CURRENT_DATABASE(), CURRENT_SCHEMA();


-- ============================================================
-- 1. Check total number of loaded records
-- ============================================================

SELECT
    COUNT(*) AS TOTAL_ROWS
FROM BANKING_TRANSACTIONS;


-- ============================================================
-- 2. Preview loaded transaction data
-- ============================================================

SELECT *
FROM BANKING_TRANSACTIONS
LIMIT 10;


-- ============================================================
-- 3. Check for NULL values in important columns
-- ============================================================

SELECT
    COUNT_IF(TRANSACTION_ID IS NULL) AS NULL_TRANSACTION_ID,
    COUNT_IF(ACCOUNT_ID IS NULL) AS NULL_ACCOUNT_ID,
    COUNT_IF(TRANSACTION_DATE IS NULL) AS NULL_TRANSACTION_DATE,
    COUNT_IF(TRANSACTION_TYPE IS NULL) AS NULL_TRANSACTION_TYPE,
    COUNT_IF(AMOUNT IS NULL) AS NULL_AMOUNT,
    COUNT_IF(CUSTOMER_ID IS NULL) AS NULL_CUSTOMER_ID,
    COUNT_IF(CUSTOMER_NAME IS NULL) AS NULL_CUSTOMER_NAME
FROM BANKING_TRANSACTIONS;


-- ============================================================
-- 4. Check transaction type distribution
-- ============================================================

SELECT
    TRANSACTION_TYPE,
    COUNT(*) AS TRANSACTION_COUNT
FROM BANKING_TRANSACTIONS
GROUP BY TRANSACTION_TYPE
ORDER BY TRANSACTION_COUNT DESC;


-- ============================================================
-- 5. Check transaction date range
-- ============================================================

SELECT
    MIN(TRANSACTION_DATE) AS MIN_TRANSACTION_DATE,
    MAX(TRANSACTION_DATE) AS MAX_TRANSACTION_DATE
FROM BANKING_TRANSACTIONS;


-- ============================================================
-- 6. Check transaction amount statistics
-- ============================================================

SELECT
    COUNT(*) AS TOTAL_TRANSACTIONS,
    MIN(AMOUNT) AS MIN_AMOUNT,
    MAX(AMOUNT) AS MAX_AMOUNT,
    AVG(AMOUNT) AS AVG_AMOUNT,
    SUM(AMOUNT) AS TOTAL_AMOUNT
FROM BANKING_TRANSACTIONS;


-- ============================================================
-- 7. Check for duplicate transaction IDs
-- ============================================================

SELECT
    TRANSACTION_ID,
    COUNT(*) AS DUPLICATE_COUNT
FROM BANKING_TRANSACTIONS
GROUP BY TRANSACTION_ID
HAVING COUNT(*) > 1
ORDER BY DUPLICATE_COUNT DESC;


-- ============================================================
-- 8. Check year-wise transaction distribution
-- ============================================================

SELECT
    TRANSACTION_YEAR,
    COUNT(*) AS TRANSACTION_COUNT,
    SUM(AMOUNT) AS TOTAL_AMOUNT
FROM BANKING_TRANSACTIONS
GROUP BY TRANSACTION_YEAR
ORDER BY TRANSACTION_YEAR;


-- ============================================================
-- 9. Check month-wise transaction distribution
-- ============================================================

SELECT
    TRANSACTION_YEAR,
    TRANSACTION_MONTH,
    COUNT(*) AS TRANSACTION_COUNT,
    SUM(AMOUNT) AS TOTAL_AMOUNT
FROM BANKING_TRANSACTIONS
GROUP BY
    TRANSACTION_YEAR,
    TRANSACTION_MONTH
ORDER BY
    TRANSACTION_YEAR,
    TRANSACTION_MONTH;