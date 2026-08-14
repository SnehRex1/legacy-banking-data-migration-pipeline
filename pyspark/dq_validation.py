from pyspark.sql import SparkSession
from pyspark.sql.functions import col, trim

# ---------------------------------------------------------
# 1. Create Spark session
# ---------------------------------------------------------
spark = SparkSession.builder \
    .appName("LegacyBanking_DQ_Validation") \
    .master("local[*]") \
    .getOrCreate()

spark.sparkContext.setLogLevel("WARN")

# ---------------------------------------------------------
# 2. Path to the cleaned Hive Parquet data
# ---------------------------------------------------------
base_path = "file:///mnt/d/Download 3/Data Engineering/Legacy project/legacy-banking-data-migration/hive_warehouse"

# Read the cleaned datasets created during the Hive stage
customers = spark.read.parquet(f"{base_path}/customers_clean")
accounts = spark.read.parquet(f"{base_path}/accounts_clean")
transactions = spark.read.parquet(f"{base_path}/transactions_clean")


# =========================================================
# CUSTOMERS DQ
# =========================================================

print("\n========== CUSTOMERS DQ ==========")

# Check NULL customer IDs
print(
    "Null customer_id:",
    customers.filter(col("customer_id").isNull()).count()
)

# Check duplicate customer IDs
print(
    "Duplicate customer_id:",
    customers.groupBy("customer_id")
             .count()
             .filter(col("count") > 1)
             .count()
)


# =========================================================
# ACCOUNTS DQ
# =========================================================

print("\n========== ACCOUNTS DQ ==========")

# Check NULL account IDs
print(
    "Null account_id:",
    accounts.filter(col("account_id").isNull()).count()
)

# Check duplicate account IDs
print(
    "Duplicate account_id:",
    accounts.groupBy("account_id")
            .count()
            .filter(col("count") > 1)
            .count()
)

# Check NULL customer IDs
print(
    "Null customer_id:",
    accounts.filter(col("customer_id").isNull()).count()
)

# Check invalid balances
print(
    "Invalid balance (NULL):",
    accounts.filter(col("balance").isNull()).count()
)


# =========================================================
# TRANSACTIONS DQ
# =========================================================

print("\n========== TRANSACTIONS DQ ==========")

# Check NULL transaction IDs
print(
    "Null transaction_id:",
    transactions.filter(col("transaction_id").isNull()).count()
)

# Check duplicate transaction IDs
print(
    "Duplicate transaction_id:",
    transactions.groupBy("transaction_id")
                .count()
                .filter(col("count") > 1)
                .count()
)

# Check NULL account IDs
print(
    "Null account_id:",
    transactions.filter(col("account_id").isNull()).count()
)

# Check blank account IDs
print(
    "Blank account_id:",
    transactions.filter(trim(col("account_id")) == "").count()
)

# Check invalid transaction types
print(
    "Invalid transaction_type:",
    transactions.filter(
        ~col("transaction_type").isin(
            "Deposit",
            "Withdrawal",
            "Transfer"
        )
    ).count()
)

# Check invalid amounts
print(
    "Invalid amount (<= 0):",
    transactions.filter(col("amount") <= 0).count()
)


# ---------------------------------------------------------
# End
# ---------------------------------------------------------
spark.stop()