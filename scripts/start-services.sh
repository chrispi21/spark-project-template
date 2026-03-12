#!/bin/bash

echo "Starting Spark cluster & Jupyter..."

docker compose -f docker/docker-compose.yml up -d --build jupyter

echo "Spark cluster & Jupyter started"

sleep 5

docker ps
