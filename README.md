# Spark Project Template

Local Apache Spark cluster + JupyterLab environment powered by Docker Compose.

## What This Includes

- Spark master at `spark://spark-master:7077`
- Two Spark workers
- JupyterLab configured to connect to the Spark cluster
- Example notebook in `notebooks/spark_session.ipynb`
- Example Spark job submission in `notebooks/spark_job_example` (launch command: `docker exec -it jupyter bash /home/jovyan/work/spark_job_example/launcher.sh`)

## Prerequisites

- Docker Desktop (or Docker Engine + Compose plugin)
- Bash shell

## Start Services

```bash
bash scripts/start-services.sh
```

This will build/start the `jupyter` service and bring up the dependent Spark services.

## Stop Services

```bash
bash scripts/stop-services.sh
```

## Service URLs

- Spark Master UI: [http://localhost:8080](http://localhost:8080)
- Spark Worker UIs:
  - [http://localhost:8081](http://localhost:8081)
  - [http://localhost:8082](http://localhost:8082)
- JupyterLab: [http://localhost:8888](http://localhost:8888)
- Spark Job UI (from notebook runs): [http://localhost:4040](http://localhost:4040)

## Running Notebook Session + spark-submit Together

In Spark Standalone mode, the first active Spark application can reserve all worker cores by default. This can cause a second app to wait with:

`Initial job has not accepted any resources`


## Resource Limits (Current Default)

This template intentionally runs a small local cluster:

- `spark-worker-1`: `1` core, `1g` memory
- `spark-worker-2`: `1` core, `1g` memory
- Total cluster capacity: `2` cores, `2g` memory

Implications:

- Running multiple Spark applications concurrently can queue jobs when capacity is exhausted.
- Interactive notebook sessions should be kept small.
- For heavier or parallel workloads, increase `SPARK_WORKER_CORES` and `SPARK_WORKER_MEMORY` in `docker/docker-compose.yml`.

## Data And Notebooks

- Notebooks are mounted from `./notebooks` to `/home/jovyan/work` in the Jupyter container.
- Local data can be mounted via `./data` to `/home/jovyan/data`.
