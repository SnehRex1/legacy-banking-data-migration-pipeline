-- ============================================================
-- LEGACY BANKING DATA MIGRATION
-- HIVE - CLEAN DATA LAYER
-- ============================================================

USE banking_legacy;


-- ============================================================
-- 1. CLEAN CUSTOMERS
-- ============================================================

DROP TABLE IF EXISTS customers_clean;

CREATE TABLE customers_clean (
    customer_id   STRING,
    customer_name STRING,
    city          STRING,
    segment       STRING
)
STORED AS PARQUET;


INSERT INTO customers_clean

SELECT
    customer_id,
    TRIM(customer_name) AS customer_name,
    TRIM(city) AS city,
    TRIM(segment) AS segment

FROM customers_raw

WHERE customer_id IS NOT NULL
  AND TRIM(customer_id) <> ''

  AND customer_name IS NOT NULL
  AND TRIM(customer_name) <> ''

  AND city IS NOT NULL
  AND TRIM(city) <> ''

  AND segment IS NOT NULL
  AND TRIM(segment) <> ''

  AND customer_id NOT IN (
      SELECT customer_id
      FROM customers_raw
      GROUP BY customer_id
      HAVING COUNT(*) > 1
  );


-- ============================================================
-- 2. CLEAN ACCOUNTS
-- ============================================================

DROP TABLE IF EXISTS accounts_clean;

CREATE TABLE accounts_clean (
    account_id   STRING,
    customer_id  STRING,
    account_type STRING,
    balance      DOUBLE,
    status       STRING
)
STORED AS PARQUET;


INSERT INTO accounts_clean

SELECT
    a.account_id,
    a.customer_id,
    a.account_type,
    CAST(a.balance AS DOUBLE) AS balance,
    a.status

FROM accounts_raw a

INNER JOIN customers_clean c
    ON a.customer_id = c.customer_id

WHERE a.account_id IS NOT NULL
  AND TRIM(a.account_id) <> ''

  AND a.customer_id IS NOT NULL
  AND TRIM(a.customer_id) <> ''

  AND a.balance IS NOT NULL
  AND TRIM(a.balance) <> ''

  AND CAST(a.balance AS DOUBLE) >= 0;


-- ============================================================
-- 3. CLEAN TRANSACTIONS
-- ============================================================

DROP TABLE IF EXISTS transactions_clean;

CREATE TABLE transactions_clean (
    transaction_id   STRING,
    account_id       STRING,
    transaction_date DATE,
    transaction_type STRING,
    amount           DOUBLE
)
STORED AS PARQUET;


INSERT INTO transactions_clean

SELECT
    t.transaction_id,

    t.account_id,

    CAST(t.transaction_date AS DATE)
        AS transaction_date,

    t.transaction_type,

    CAST(t.amount AS DOUBLE)
        AS amount

FROM transactions_raw t

INNER JOIN accounts_clean a
    ON t.account_id = a.account_id

WHERE t.account_id IS NOT NULL
  AND TRIM(t.account_id) <> ''

  AND t.transaction_type IN (
      'Deposit',
      'Withdrawal',
      'Transfer'
  )

  AND t.amount IS NOT NULL
  AND TRIM(t.amount) <> ''

  AND CAST(t.amount AS DOUBLE) > 0

  AND CAST(t.transaction_date AS DATE) <= CURRENT_DATE

  -- Remove duplicate transaction IDs
  AND t.transaction_id NOT IN (
      SELECT transaction_id
      FROM transactions_raw
      GROUP BY transaction_id
      HAVING COUNT(*) > 1
  );


-- ============================================================
-- 4. CLEAN ROW COUNT VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS clean_customer_rows
FROM customers_clean;


SELECT
    COUNT(*) AS clean_account_rows
FROM accounts_clean;


SELECT
    COUNT(*) AS clean_transaction_rows
FROM transactions_clean;


-- ============================================================
-- 5. FINAL REFERENTIAL-INTEGRITY CHECK
-- ============================================================

SELECT
    COUNT(*) AS orphan_transactions
FROM transactions_clean t

LEFT JOIN accounts_clean a
    ON t.account_id = a.account_id

WHERE a.account_id IS NULL;