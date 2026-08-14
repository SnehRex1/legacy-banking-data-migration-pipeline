CREATE DATABASE IF NOT EXISTS banking_legacy;

USE banking_legacy;

CREATE TABLE IF NOT EXISTS customers (
    customer_id STRING,
    customer_name STRING,
    city STRING,
    segment STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

CREATE TABLE IF NOT EXISTS accounts (
    account_id STRING,
    customer_id STRING,
    account_type STRING,
    balance DECIMAL(15,2),
    status STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id STRING,
    account_id STRING,
    transaction_date STRING,
    transaction_type STRING,
    amount DECIMAL(15,2)
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

SHOW DATABASES;
SHOW TABLES;
