# Spark Project Template

Local Apache Spark cluster + JupyterLab + MinIO (S3-compatible storage) environment powered by Docker Compose.

## What This Includes

| Service | Description |
|---|---|
| `spark-master` | Spark standalone master at `spark://spark-master:7077` |
| `spark-worker-1` | Spark worker (1 core, 1 GB) |
| `spark-worker-2` | Spark worker (1 core, 1 GB) |
| `jupyter` | JupyterLab pre-configured to connect to the Spark cluster |
| `minio` | S3-compatible object store; pre-configured as the Spark SQL warehouse |

S3A access is pre-configured in all containers via `docker/spark-defaults.conf`. The `warehouse` MinIO bucket is used as `spark.sql.warehouse.dir`, so Hive-managed tables are stored in MinIO automatically.

## Prerequisites

- Docker Desktop (or Docker Engine + Compose plugin)
- Bash shell

## Start Services

```bash
bash scripts/start-services.sh
```

This builds and starts all containers, then creates the `warehouse` bucket in MinIO. Pass `--build` to force a Docker image rebuild:

```bash
bash scripts/start-services.sh --build
```

## Stop Services

```bash
bash scripts/stop-services.sh
```

## Service URLs

| Service | URL |
|---|---|
| JupyterLab | http://localhost:8888 |
| Spark Master UI | http://localhost:8080 |
| Spark Worker 1 UI | http://localhost:8081 |
| Spark Worker 2 UI | http://localhost:8082 |
| Spark Job UI (active jobs) | http://localhost:4040 |
| MinIO S3 API | http://localhost:9000 |
| MinIO Web Console | http://localhost:9001 |

MinIO credentials: `minio` / `minio123`

## Repository Structure

```
notebooks/
  s3-example.ipynb              # Interactive notebook: read/write to MinIO via S3A
  load_sample_data_job/
    job.py                      # Reads sample.csv, writes Parquet to s3a://warehouse/sample
    launcher.sh                 # spark-submit wrapper for the job above
  spark_job_example/
    job.py                      # Creates a Hive-managed table via Spark SQL
    launcher.sh                 # spark-submit wrapper for the job above

jupyter-data/
  sample.csv                    # Sample CSV mounted into the Jupyter container at /home/jovyan/data/

docker/
  docker-compose.yml
  Dockerfile.spark-base         # Spark 3.5.7 + Hadoop AWS / S3A JARs
  Dockerfile.jupyter            # JupyterLab built on top of spark-base
  spark-defaults.conf           # Cluster & S3A defaults injected into every container

scripts/
  start-services.sh
  stop-services.sh
```

## Running Notebooks

Open JupyterLab at http://localhost:8888. Notebooks inside `./notebooks` are mounted at `/home/jovyan/work` in the container.

### S3 / MinIO Example (`notebooks/s3-example.ipynb`)

Demonstrates reading and writing data to the MinIO `warehouse` bucket using a Hive-managed table:

```python
from pyspark.sql import SparkSession

spark = (
    SparkSession.builder
    .appName("spark-minio")
    .enableHiveSupport()
    .getOrCreate()
)

spark.range(10).write.mode("overwrite").saveAsTable("test_table")
spark.sql("SELECT * FROM test_table").show()
spark.sql("SHOW CREATE TABLE test_table").show(truncate=False)
```

## Submitting Jobs to the Cluster

Jobs live under `notebooks/` and are submitted from inside the `jupyter` container with `spark-submit`. The launcher scripts inside each job folder wrap the submit command.

### `spark_job_example` — Hive table via Spark SQL

Creates a Hive-managed table backed by the MinIO warehouse:

```bash
docker exec -it jupyter bash /home/jovyan/work/spark_job_example/launcher.sh
```

What the job does (`notebooks/spark_job_example/job.py`):

```python
spark.range(10).createOrReplaceTempView("test_view")
spark.sql("DROP TABLE IF EXISTS test_table")
spark.sql("CREATE TABLE test_table AS SELECT * FROM test_view")
spark.sql("SHOW CREATE TABLE test_table").show(truncate=False)
```

### `load_sample_data_job` — CSV → Parquet on S3

Reads `sample.csv` from the local data mount and writes it to `s3a://warehouse/sample` as Parquet:

```bash
docker exec -it jupyter bash /home/jovyan/work/load_sample_data_job/launcher.sh
```

What the job does (`notebooks/load_sample_data_job/job.py`):

```python
df = spark.read.format("csv").option("header", True).load("file:///home/jovyan/data/sample.csv")
df.write.format("parquet").mode("overwrite").save("s3a://warehouse/sample")
```

> **Note:** This job uses `.master("local[*]")` so it accesses the local filesystem for the CSV source. The Parquet output is still written to MinIO over S3A.

### Running an Ad-hoc `spark-submit`

You can submit any script directly without a launcher:

```bash
docker exec -it jupyter spark-submit \
  work/<your_job_folder>/job.py
```

## Resource Limits

This template runs a small local cluster by default:

| Worker | Cores | Memory |
|---|---|---|
| `spark-worker-1` | 1 | 1 GB |
| `spark-worker-2` | 1 | 1 GB |
| **Total** | **2** | **2 GB** |

In Spark Standalone mode the first active application can reserve all worker resources, causing a second app to queue with:

```
Initial job has not accepted any resources
```

To avoid this, stop the notebook kernel before running `spark-submit`, or increase capacity by editing `SPARK_WORKER_CORES` and `SPARK_WORKER_MEMORY` in `docker/docker-compose.yml`.
