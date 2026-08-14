from pyspark.sql import SparkSession

# Create a local Spark session
spark = SparkSession.builder \
    .appName("LegacyBankingMigration") \
    .master("local[*]") \
    .getOrCreate()

print("Spark version:", spark.version)
print("Spark session created successfully!")

# Stop Spark cleanly
spark.stop()