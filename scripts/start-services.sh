#!/bin/bash

BUILD_FLAG=""

for arg in "$@"; do
  case $arg in
    --build)
      BUILD_FLAG="--build"
      ;;
  esac
done

echo "Starting Spark cluster & Jupyter..."

# Build spark-base first so spark-base:latest exists locally (not pulled from Docker Hub) before
# Jupyter's Dockerfile and spark-master/workers use that image.
# docker compose -f docker/docker-compose.yml build spark-base

# docker compose -f docker/docker-compose.yml up -d $BUILD_FLAG

echo "Spark cluster & Jupyter started"

sleep 5

docker exec minio /usr/bin/mc alias set local http://localhost:9000 minio minio123
docker exec minio /usr/bin/mc mb --ignore-existing local/warehouse

echo "'warehouse' bucket created"

docker exec minio /usr/bin/mc mb --ignore-existing local/landing-zone

for f in scripts/uam_categories.snappy.parquet \
         scripts/uam_offers.snappy.parquet \
         scripts/uam_orders.snappy.parquet; do
  docker cp "$f" minio:/tmp/
done

docker exec minio sh -c '/usr/bin/mc cp /tmp/*.parquet local/landing-zone/'

echo "'landing-zone' bucket created & sample data uploaded"

docker ps
