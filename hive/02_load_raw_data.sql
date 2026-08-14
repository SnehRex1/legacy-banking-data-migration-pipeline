-- ============================================================
-- LEGACY BANKING DATA MIGRATION
-- HIVE - LOAD RAW DATA
-- ============================================================

USE banking_legacy;


-- ============================================================
-- 1. LOAD CUSTOMERS
-- ============================================================

LOAD DATA LOCAL INPATH
'/tmp/banking_data/customers.csv'
OVERWRITE INTO TABLE customers_raw;


-- ============================================================
-- 2. LOAD ACCOUNTS
-- ============================================================

LOAD DATA LOCAL INPATH
'/tmp/banking_data/accounts.csv'
OVERWRITE INTO TABLE accounts_raw;


-- ============================================================
-- 3. LOAD TRANSACTIONS
-- ============================================================

LOAD DATA LOCAL INPATH
'/tmp/banking_data/transactions.csv'
OVERWRITE INTO TABLE transactions_raw;


-- ============================================================
-- 4. VERIFY ROW COUNTS
-- ============================================================

SELECT COUNT(*) AS customer_rows
FROM customers_raw;

SELECT COUNT(*) AS account_rows
FROM accounts_raw;

SELECT COUNT(*) AS transaction_rows
FROM transactions_raw;


-- Expected:
-- customers    = 10,010
-- accounts     = 15,000
-- transactions = 100,100


-- ============================================================
-- 5. SAMPLE DATA
-- ============================================================

SELECT *
FROM customers_raw
LIMIT 10;

SELECT *
FROM accounts_raw
LIMIT 10;

SELECT *
FROM transactions_raw
LIMIT 10;