-- ============================================================
-- LEGACY BANKING DATA MIGRATION
-- HIVE - DATA QUALITY PROFILING & VALIDATION
-- ============================================================

USE banking_legacy;


-- ============================================================
-- 1. CUSTOMERS - BASIC DQ PROFILE
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT customer_id) AS unique_customer_ids,

    SUM(
        CASE
            WHEN customer_id IS NULL
              OR TRIM(customer_id) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_customer_id,

    SUM(
        CASE
            WHEN customer_name IS NULL
              OR TRIM(customer_name) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_customer_name,

    SUM(
        CASE
            WHEN city IS NULL
              OR TRIM(city) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_city,

    SUM(
        CASE
            WHEN segment IS NULL
              OR TRIM(segment) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_segment

FROM customers_raw;


-- ============================================================
-- 2. CUSTOMER DUPLICATES
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS occurrences
FROM customers_raw
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- ============================================================
-- 3. ACCOUNTS - BASIC DQ PROFILE
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT account_id) AS unique_account_ids,

    SUM(
        CASE
            WHEN account_id IS NULL
              OR TRIM(account_id) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_account_id,

    SUM(
        CASE
            WHEN customer_id IS NULL
              OR TRIM(customer_id) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_customer_id,

    SUM(
        CASE
            WHEN balance IS NULL
              OR TRIM(balance) = ''
            THEN 1 ELSE 0
        END
    ) AS null_balance,

    SUM(
        CASE
            WHEN CAST(balance AS DOUBLE) < 0
            THEN 1 ELSE 0
        END
    ) AS negative_balance

FROM accounts_raw;


-- ============================================================
-- 4. ACCOUNT BALANCE FORMAT VALIDATION
-- ============================================================

SELECT
    balance,
    COUNT(*) AS occurrences
FROM accounts_raw
WHERE balance IS NOT NULL
  AND TRIM(balance) NOT RLIKE '^-?[0-9]+(\\.[0-9]+)?$'
GROUP BY balance
ORDER BY occurrences DESC;


-- ============================================================
-- 5. ACCOUNT -> CUSTOMER REFERENTIAL INTEGRITY
-- ============================================================

SELECT
    a.customer_id,
    COUNT(*) AS account_count
FROM accounts_raw a
LEFT JOIN customers_raw c
    ON a.customer_id = c.customer_id
WHERE a.customer_id IS NOT NULL
  AND TRIM(a.customer_id) <> ''
  AND c.customer_id IS NULL
GROUP BY a.customer_id
ORDER BY account_count DESC;


-- ============================================================
-- 6. TRANSACTION DUPLICATES
-- ============================================================

SELECT
    transaction_id,
    COUNT(*) AS occurrences
FROM transactions_raw
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- ============================================================
-- 7. MISSING TRANSACTION ACCOUNT IDS
-- ============================================================

SELECT
    COUNT(*) AS missing_account_id
FROM transactions_raw
WHERE account_id IS NULL
   OR TRIM(account_id) = '';


-- ============================================================
-- 8. TRANSACTION TYPE DISTRIBUTION
-- ============================================================

SELECT
    transaction_type,
    COUNT(*) AS row_count
FROM transactions_raw
GROUP BY transaction_type
ORDER BY row_count DESC;


-- ============================================================
-- 9. INVALID TRANSACTION TYPES
-- ============================================================

SELECT
    transaction_id,
    account_id,
    transaction_date,
    transaction_type,
    amount
FROM transactions_raw
WHERE transaction_type NOT IN (
    'Deposit',
    'Withdrawal',
    'Transfer'
)
ORDER BY transaction_type, transaction_id;


-- ============================================================
-- 10. INVALID AMOUNT PROFILING
-- ============================================================

SELECT
    SUM(
        CASE
            WHEN CAST(amount AS DOUBLE) <= 0
            THEN 1 ELSE 0
        END
    ) AS invalid_amount_rows,

    MIN(CAST(amount AS DOUBLE)) AS minimum_amount,

    MAX(CAST(amount AS DOUBLE)) AS maximum_amount

FROM transactions_raw;


-- ============================================================
-- 11. INVALID AMOUNT RECORDS
-- ============================================================

SELECT
    transaction_id,
    account_id,
    transaction_date,
    transaction_type,
    amount
FROM transactions_raw
WHERE CAST(amount AS DOUBLE) <= 0
ORDER BY CAST(amount AS DOUBLE);


-- ============================================================
-- 12. FUTURE TRANSACTION DATES
-- ============================================================

SELECT
    COUNT(*) AS future_transactions
FROM transactions_raw
WHERE CAST(transaction_date AS DATE) > CURRENT_DATE;


-- ============================================================
-- 13. TRANSACTION -> ACCOUNT REFERENTIAL INTEGRITY
-- ============================================================

SELECT
    t.account_id,
    COUNT(*) AS transaction_count
FROM transactions_raw t
LEFT JOIN accounts_raw a
    ON t.account_id = a.account_id
WHERE t.account_id IS NOT NULL
  AND TRIM(t.account_id) <> ''
  AND a.account_id IS NULL
GROUP BY t.account_id
ORDER BY transaction_count DESC;