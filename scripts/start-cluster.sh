#!/bin/bash

echo "Starting Spark cluster..."

docker compose -f docker/docker-compose.yml up -d

echo "Spark cluster started"

sleep 5

docker ps
