-- ============================================================
-- LEGACY BANKING DATA MIGRATION
-- HIVE - TRANSACTION PARTITIONING
-- ============================================================

USE banking_legacy;


-- ============================================================
-- 1. ENABLE DYNAMIC PARTITIONING
-- ============================================================

SET hive.exec.dynamic.partition = true;

SET hive.exec.dynamic.partition.mode = nonstrict;


-- ============================================================
-- 2. CREATE PARTITIONED TABLE
-- ============================================================

DROP TABLE IF EXISTS transactions_clean_partitioned;

CREATE TABLE transactions_clean_partitioned (
    transaction_id   STRING,
    account_id       STRING,
    transaction_date DATE,
    transaction_type STRING,
    amount           DOUBLE
)
PARTITIONED BY (
    year  INT,
    month INT
)
STORED AS PARQUET;


-- ============================================================
-- 3. INSERT DATA INTO YEAR/MONTH PARTITIONS
-- ============================================================

INSERT INTO transactions_clean_partitioned
PARTITION (year, month)

SELECT
    transaction_id,

    account_id,

    transaction_date,

    transaction_type,

    amount,

    YEAR(transaction_date) AS year,

    MONTH(transaction_date) AS month

FROM transactions_clean;


-- ============================================================
-- 4. VALIDATE ROW COUNT
-- ============================================================

SELECT
    COUNT(*) AS total_rows
FROM transactions_clean_partitioned;


-- ============================================================
-- 5. SHOW PARTITIONS
-- ============================================================

SHOW PARTITIONS transactions_clean_partitioned;


-- ============================================================
-- 6. SAMPLE PARTITION QUERY
-- ============================================================

SELECT
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM transactions_clean_partitioned
WHERE year = 2026
  AND month = 1;


-- ============================================================
-- 7. PARTITION DISTRIBUTION
-- ============================================================

SELECT
    year,
    month,
    COUNT(*) AS transaction_count
FROM transactions_clean_partitioned
GROUP BY year, month
ORDER BY year, month;