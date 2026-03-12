from pyspark.sql import SparkSession
spark = (
    SparkSession.builder
    .appName("spark-job-example")
    .master("spark://spark-master:7077")
    .getOrCreate()
)

spark.range(10).show()

spark.stop()
