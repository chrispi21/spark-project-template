#!/bin/bash

echo "Starting Spark cluster & Jupyter..."

docker compose -f docker/docker-compose.yml up -d --build jupyter

echo "Spark cluster & Jupyter started"

docker exec -it minio mc alias set local http://localhost:9000 minio minio123
docker exec -it minio mc mb local/warehouse

sleep 5

docker ps
