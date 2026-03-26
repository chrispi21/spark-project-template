#!/bin/bash

CLEAN=false

for arg in "$@"; do
  case $arg in
    --clean)
      CLEAN=true
      ;;
  esac
done

echo "Stopping Spark cluster & Jupyter..."

docker compose -f docker/docker-compose.yml down

echo "Spark cluster & Jupyter stopped"

if [ "$CLEAN" = true ]; then
  sleep 5
  rm -rf minio-data/*
  echo "minio-data cleared"
fi

docker ps
