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

docker compose -f docker/docker-compose.yml up -d $BUILD_FLAG

echo "Spark cluster & Jupyter started"

sleep 5

docker exec minio /usr/bin/mc alias set local http://localhost:9000 minio minio123
docker exec minio /usr/bin/mc mb --ignore-existing local/warehouse

echo "'warehouse' bucket created"

docker exec minio /usr/bin/mc mb --ignore-existing local/landing-zone
docker cp scripts/s3-sample.csv minio:/tmp/s3-sample.csv
docker exec minio /usr/bin/mc cp /tmp/s3-sample.csv local/landing-zone/s3-sample.csv

echo "'landing-zone' bucket created & sample data uploaded"

docker ps
