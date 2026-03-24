from pyspark.sql import SparkSession
spark = (
    SparkSession.builder
    # local[*] to access local files for jupyter
    .master("local[*]")
    .appName("load-sample-data")    
    .getOrCreate()
)

df = spark.read.format("csv").option("header", True).load("file:///home/jovyan/data/sample.csv")
df.write.format("parquet").mode("overwrite").save("s3a://warehouse/sample")

spark.stop()
