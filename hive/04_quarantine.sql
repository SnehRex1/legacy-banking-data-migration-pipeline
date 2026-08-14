-- ============================================================
-- LEGACY BANKING DATA MIGRATION
-- HIVE - QUARANTINE INVALID RECORDS
-- ============================================================

USE banking_legacy;


-- ============================================================
-- 1. CUSTOMER QUARANTINE
-- ============================================================

DROP TABLE IF EXISTS customers_quarantine;

CREATE TABLE customers_quarantine (
    customer_id   STRING,
    customer_name STRING,
    city          STRING,
    segment       STRING,
    quarantine_reason STRING
)
STORED AS PARQUET;


INSERT INTO customers_quarantine

SELECT
    customer_id,
    customer_name,
    city,
    segment,

    CASE
        WHEN customer_id IS NULL
          OR TRIM(customer_id) = ''
            THEN 'MISSING_CUSTOMER_ID'

        WHEN customer_name IS NULL
          OR TRIM(customer_name) = ''
            THEN 'MISSING_CUSTOMER_NAME'

        WHEN city IS NULL
          OR TRIM(city) = ''
            THEN 'MISSING_CITY'

        WHEN segment IS NULL
          OR TRIM(segment) = ''
            THEN 'MISSING_SEGMENT'

        ELSE 'INVALID_CUSTOMER_RECORD'
    END AS quarantine_reason

FROM customers_raw

WHERE
       customer_id IS NULL
    OR TRIM(customer_id) = ''
    OR customer_name IS NULL
    OR TRIM(customer_name) = ''
    OR city IS NULL
    OR TRIM(city) = ''
    OR segment IS NULL
    OR TRIM(segment) = '';


-- ============================================================
-- 2. ACCOUNT QUARANTINE
-- ============================================================

DROP TABLE IF EXISTS accounts_quarantine;

CREATE TABLE accounts_quarantine (
    account_id   STRING,
    customer_id  STRING,
    account_type STRING,
    balance      STRING,
    status       STRING,
    quarantine_reason STRING
)
STORED AS PARQUET;


INSERT INTO accounts_quarantine

SELECT
    a.account_id,
    a.customer_id,
    a.account_type,
    a.balance,

    a.status,

    CASE
        WHEN a.account_id IS NULL
          OR TRIM(a.account_id) = ''
            THEN 'MISSING_ACCOUNT_ID'

        WHEN a.customer_id IS NULL
          OR TRIM(a.customer_id) = ''
            THEN 'MISSING_CUSTOMER_ID'

        WHEN a.balance IS NULL
          OR TRIM(a.balance) = ''
            THEN 'MISSING_BALANCE'

        WHEN CAST(a.balance AS DOUBLE) < 0
            THEN 'NEGATIVE_BALANCE'

        WHEN c.customer_id IS NULL
            THEN 'ORPHAN_CUSTOMER_ID'

        ELSE 'INVALID_ACCOUNT_RECORD'
    END AS quarantine_reason

FROM accounts_raw a

LEFT JOIN customers_raw c
    ON a.customer_id = c.customer_id

WHERE
       a.account_id IS NULL
    OR TRIM(a.account_id) = ''
    OR a.customer_id IS NULL
    OR TRIM(a.customer_id) = ''
    OR a.balance IS NULL
    OR TRIM(a.balance) = ''
    OR CAST(a.balance AS DOUBLE) < 0
    OR c.customer_id IS NULL;


-- ============================================================
-- 3. TRANSACTION QUARANTINE
-- ============================================================

DROP TABLE IF EXISTS transactions_quarantine;

CREATE TABLE transactions_quarantine (
    transaction_id   STRING,
    account_id       STRING,
    transaction_date STRING,
    transaction_type STRING,
    amount           STRING,
    quarantine_reason STRING
)
STORED AS PARQUET;


INSERT INTO transactions_quarantine

SELECT
    t.transaction_id,
    t.account_id,
    t.transaction_date,
    t.transaction_type,
    t.amount,

    CASE

        WHEN t.account_id IS NULL
          OR TRIM(t.account_id) = ''
            THEN 'MISSING_ACCOUNT_ID'

        WHEN t.transaction_type NOT IN (
            'Deposit',
            'Withdrawal',
            'Transfer'
        )
            THEN 'INVALID_TRANSACTION_TYPE'

        WHEN t.amount IS NULL
          OR TRIM(t.amount) = ''
            THEN 'MISSING_AMOUNT'

        WHEN CAST(t.amount AS DOUBLE) <= 0
            THEN 'INVALID_AMOUNT'

        WHEN CAST(t.transaction_date AS DATE) > CURRENT_DATE
            THEN 'FUTURE_TRANSACTION_DATE'

        WHEN a.account_id IS NULL
            THEN 'ORPHAN_ACCOUNT_ID'

        ELSE 'INVALID_TRANSACTION_RECORD'

    END AS quarantine_reason

FROM transactions_raw t

LEFT JOIN accounts_raw a
    ON t.account_id = a.account_id

WHERE
       t.account_id IS NULL
    OR TRIM(t.account_id) = ''

    OR t.transaction_type NOT IN (
        'Deposit',
        'Withdrawal',
        'Transfer'
    )

    OR t.amount IS NULL
    OR TRIM(t.amount) = ''

    OR CAST(t.amount AS DOUBLE) <= 0

    OR CAST(t.transaction_date AS DATE) > CURRENT_DATE

    OR a.account_id IS NULL;


-- ============================================================
-- 4. QUARANTINE SUMMARY
-- ============================================================

SELECT
    quarantine_reason,
    COUNT(*) AS row_count
FROM customers_quarantine
GROUP BY quarantine_reason
ORDER BY row_count DESC;


SELECT
    quarantine_reason,
    COUNT(*) AS row_count
FROM accounts_quarantine
GROUP BY quarantine_reason
ORDER BY row_count DESC;


SELECT
    quarantine_reason,
    COUNT(*) AS row_count
FROM transactions_quarantine
GROUP BY quarantine_reason
ORDER BY row_count DESC;