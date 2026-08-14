from pyspark.sql import SparkSession
from pyspark.sql.functions import col


# =========================================================
# 1. CREATE SPARK SESSION
# =========================================================

spark = (
    SparkSession.builder
    .appName("LegacyBanking_Joins")
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
# 4. TRANSFORMATIONS
# =========================================================

from pyspark.sql.functions import trim, year, month


customers_transformed = (
    customers
    .withColumn("customer_id", trim(col("customer_id")))
    .withColumn("customer_name", trim(col("customer_name")))
    .withColumn("city", trim(col("city")))
    .withColumn("segment", trim(col("segment")))
)


accounts_transformed = (
    accounts
    .withColumn("account_id", trim(col("account_id")))
    .withColumn("customer_id", trim(col("customer_id")))
    .withColumn("account_type", trim(col("account_type")))
    .withColumn("status", trim(col("status")))
)


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
# 5. JOIN TRANSACTIONS WITH ACCOUNTS
# =========================================================

transaction_accounts = (
    transactions_transformed
    .join(
        accounts_transformed,
        transactions_transformed.account_id
        == accounts_transformed.account_id,
        "left"
    )
    .select(
        transactions_transformed["*"],
        accounts_transformed["customer_id"],
        accounts_transformed["account_type"],
        accounts_transformed["balance"],
        accounts_transformed["status"]
    )
)


# =========================================================
# 6. JOIN WITH CUSTOMERS
# =========================================================

banking_integrated = (
    transaction_accounts
    .join(
        customers_transformed,
        transaction_accounts.customer_id
        == customers_transformed.customer_id,
        "left"
    )
    .select(
        transaction_accounts["*"],
        customers_transformed["customer_name"],
        customers_transformed["city"],
        customers_transformed["segment"]
    )
)


# =========================================================
# 7. DISPLAY INTEGRATED DATA
# =========================================================

print("\n========== INTEGRATED BANKING DATA ==========")

banking_integrated.show(
    10,
    truncate=False
)


# =========================================================
# 8. DISPLAY SCHEMA
# =========================================================

print("\n========== INTEGRATED SCHEMA ==========")

banking_integrated.printSchema()


# =========================================================
# 9. CHECK ROW COUNT
# =========================================================

print("\n========== ROW COUNT ==========")

print(
    "Integrated transaction rows:",
    banking_integrated.count()
)


# =========================================================
# 10. STOP SPARK
# =========================================================

spark.stop()