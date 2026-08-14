from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("LegacyBankingMigration") \
    .master("local[*]") \
    .getOrCreate()

spark.sparkContext.setLogLevel("WARN")

base_path = "file:///mnt/d/Download 3/Data Engineering/Legacy project/legacy-banking-data-migration/hive_warehouse"


# Read the cleaned Hive Parquet datasets
customers = spark.read.parquet(
    f"{base_path}/customers_clean"
)

accounts = spark.read.parquet(
    f"{base_path}/accounts_clean"
)

transactions = spark.read.parquet(
    f"{base_path}/transactions_clean"
)

# Show schemas
print("\n=== CUSTOMERS CLEAN ===")
customers.printSchema()

print("\n=== ACCOUNTS CLEAN ===")
accounts.printSchema()

print("\n=== TRANSACTIONS CLEAN ===")
transactions.printSchema()

# Verify row counts
print("\n=== ROW COUNTS ===")
print("Customers:", customers.count())
print("Accounts:", accounts.count())
print("Transactions:", transactions.count())

spark.stop()