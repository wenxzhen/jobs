#!/usr/bin/env bash
unset HIVE_HOME
unset HIVE_CONF_DIR
export HIVE_SERVER2_THRIFT_PORT=10001
export HIVE_SERVER2_THRIFT_BIND_HOST=0.0.0.0
sbin/start-thriftserver.sh --conf spark.sql.hive.thriftServer.singleSession=true \
--conf spark.hadoop.yarn.timeline-service.enabled=false \
--conf spark.sql.hive.convertMetastoreOrc=false \
--conf spark.dynamicAllocation.enabled=true \
--conf spark.shuffle.service.enabled=true \
--conf spark.dynamicAllocation.initialExecutors=2 \
--conf spark.dynamicAllocation.maxExecutors=25 \
--conf spark.dynamicAllocation.minExecutors=2 \
--master yarn \
--executor-cores 6 \
--queue default \
--conf spark.yarn.executor.memoryOverhead=2G \
--executor-memory 20G \
--driver-memory 40G \
--files hdfs://csdncluster/apps/spark/log4j.properties