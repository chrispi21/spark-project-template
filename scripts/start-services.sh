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

docker exec -it minio mc alias set local http://localhost:9000 minio minio123
docker exec -it minio mc mb local/warehouse

echo "'warehouse' bucket created"

docker ps
