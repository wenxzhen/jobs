#!/usr/bin/env bash

# service crond status 确认 crond服务器状态
# */2 * * * * sh /data/bigdata/spark-2.1.1-bin-hadoop2.7/thrift_server_ck.sh > /tmp/thrift_server_ck.log 2>&1

source /etc/profile

START_SCRIPT=start-thrirfserver.sh

pid=`jps -lm | grep 'org.apache.spark.sql.hive.thriftserver.HiveThriftServer2' | awk '{ print $1 }'`

http_code=`curl -Is -m 10 -w %{http_code} -o /dev/null http://VCG-HDP-CLI-01:4040`

datetime=`date '+%Y-%m-%d %H:%M:%S'`
echo "Check Time: "$datetime

if [ $pid -a $http_code == '302' ];then
  echo "PID: "$pid
  echo "HTTP Code: "$http_code
  exit 0
fi

echo "Spark ThriftServer is not running !"

echo "cd $SPARK_HOME"

cd $SPARK_HOME

sh $START_SCRIP