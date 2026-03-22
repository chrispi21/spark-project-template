#!/bin/bash

echo "Starting Spark cluster & Jupyter..."

docker compose -f docker/docker-compose.yml up -d --build

echo "Spark cluster & Jupyter started"

sleep 5

docker exec -it minio mc alias set local http://localhost:9000 minio minio123
docker exec -it minio mc mb local/warehouse

echo "'warehouse' bucket created"

docker ps
