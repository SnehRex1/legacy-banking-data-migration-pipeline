from pyspark.sql import SparkSession

spark = (
    SparkSession.builder
    .appName("LegacyBankingMigration")
    .master("local[*]")
    .enableHiveSupport()
    .getOrCreate()
)

print("Spark version:", spark.version)

# Show Hive databases
spark.sql("SHOW DATABASES").show()

# Switch to the legacy banking database
spark.sql("USE banking_legacy")

# Show tables inside banking_legacy
spark.sql("SHOW TABLES").show()

spark.stop()