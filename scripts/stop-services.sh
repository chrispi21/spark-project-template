#!/bin/bash

echo "Stopping Spark cluster & Jupyter..."

docker compose -f docker/docker-compose.yml down

echo "Spark cluster & Jupyter stopped"

sleep 5

docker ps
