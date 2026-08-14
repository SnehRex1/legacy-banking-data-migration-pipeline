from pyspark.sql import SparkSession
from pyspark.sql.functions import col, trim, year, month


# =========================================================
# 1. CREATE SPARK SESSION
# =========================================================

spark = (
    SparkSession.builder
    .appName("LegacyBanking_Transformations")
    .master("local[*]")
    .getOrCreate()
)

spark.sparkContext.setLogLevel("WARN")


# =========================================================
# 2. PATH TO HIVE CLEAN PARQUET DATA
# =========================================================

base_path = (
    "file:///mnt/d/Download 3/"
    "Data Engineering/Legacy project/"
    "legacy-banking-data-migration/hive_warehouse"
)


# =========================================================
# 3. READ CLEAN DATASETS
# =========================================================

customers = spark.read.parquet(
    f"{base_path}/customers_clean"
)

accounts = spark.read.parquet(
    f"{base_path}/accounts_clean"
)

transactions = spark.read.parquet(
    f"{base_path}/transactions_clean"
)


# =========================================================
# 4. CUSTOMERS TRANSFORMATION
# =========================================================

customers_transformed = (
    customers
    .withColumn("customer_id", trim(col("customer_id")))
    .withColumn("customer_name", trim(col("customer_name")))
    .withColumn("city", trim(col("city")))
    .withColumn("segment", trim(col("segment")))
)


# =========================================================
# 5. ACCOUNTS TRANSFORMATION
# =========================================================

accounts_transformed = (
    accounts
    .withColumn("account_id", trim(col("account_id")))
    .withColumn("customer_id", trim(col("customer_id")))
    .withColumn("account_type", trim(col("account_type")))
    .withColumn("status", trim(col("status")))
)


# =========================================================
# 6. TRANSACTIONS TRANSFORMATION
# =========================================================

transactions_transformed = (
    transactions
    .withColumn("transaction_id", trim(col("transaction_id")))
    .withColumn("account_id", trim(col("account_id")))
    .withColumn("transaction_type", trim(col("transaction_type")))
    .withColumn(
        "transaction_year",
        year(col("transaction_date"))
    )
    .withColumn(
        "transaction_month",
        month(col("transaction_date"))
    )
)


# =========================================================
# 7. DISPLAY RESULTS
# =========================================================

print("\n========== CUSTOMERS TRANSFORMED ==========")
customers_transformed.show(5, truncate=False)


print("\n========== ACCOUNTS TRANSFORMED ==========")
accounts_transformed.show(5, truncate=False)


print("\n========== TRANSACTIONS TRANSFORMED ==========")
transactions_transformed.show(5, truncate=False)


# =========================================================
# 8. DISPLAY SCHEMAS
# =========================================================

print("\n========== CUSTOMERS SCHEMA ==========")
customers_transformed.printSchema()


print("\n========== ACCOUNTS SCHEMA ==========")
accounts_transformed.printSchema()


print("\n========== TRANSACTIONS SCHEMA ==========")
transactions_transformed.printSchema()


# =========================================================
# 9. STOP SPARK
# =========================================================

spark.stop()