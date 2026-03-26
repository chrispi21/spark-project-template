#!/bin/bash

DERBY_HOME=$(mktemp -d)
spark-submit \
  --conf "spark.driver.extraJavaOptions=-Dderby.system.home=${DERBY_HOME}" \
  work/spark_job_example/job.py
