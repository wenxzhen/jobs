
# service crond status 确认 crond服务器状态
# */2 * * * * sh /data/bigdata/spark-2.1.1-bin-hadoop2.7/thrift_server_ck.sh > /tmp/thrift_server_ck.log 2>&1

source /etc/profile

START_SCRIPT=/data/bigdata/spark-2.1.1-bin-hadoop2.7/start-thrift.sh

pid=`jps -lm | grep 'org.apache.spark.sql.hive.thriftserver.HiveThriftServer2' | awk '{ print $1 }'`

datetime=`date '+%Y-%m-%d %H:%M:%S'`
echo "Check Time: "$datetime

if [ $pid ];then
  echo "PID: "$pid
  exit 0
fi

echo "Spark ThriftServer is not running !"

sh $START_SCRIPT