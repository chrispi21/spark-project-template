from pyspark.sql import SparkSession
spark = (
    SparkSession.builder
    .appName("spark-job-example")    
    .enableHiveSupport()
    .getOrCreate()
)

table_name = "test_table"
view_name = "test_view"

spark.range(10).createOrReplaceTempView(view_name)
spark.sql(f"DROP TABLE IF EXISTS {table_name}")
spark.sql(f"CREATE TABLE {table_name} AS SELECT * FROM {view_name}")
spark.sql(f"SHOW CREATE TABLE {table_name}").show(truncate=False)

spark.stop()
