#!/bin/bash

base_dir=$(cd "$(dirname "$0")";pwd)
host=`hostname`
source /etc/profile
echo `date`

pid=`jps -mlv | grep 'csdn-flume-log-collector-kafka-hdfs' | awk '{ print $1}'`
echo "PID: "$pid

echo "beans" > $base_dir/jmxinput

consumer_id=`java -jar $base_dir/jmxterm-1.0.0-uber.jar -l $host:5446 -v silent -n -i $base_dir/jmxinput | grep type=consumer-metrics `
echo "get -b ${consumer_id} response-rate"
echo "get -b ${consumer_id} response-rate" > $base_dir/jmxinput 

metrics=`java -jar $base_dir/jmxterm-1.0.0-uber.jar -l $host:5446 -v silent -n -i $base_dir/jmxinput | awk '{ print $3}' `
echo "Metrics is: "$metrics

value=`echo $metrics | tr "." " " | awk '{ print $1}'`
echo "Int value: "$value

if [ $value -eq "0" ];then
    echo "kill -9 $pid"
    kill -9 $pid
fi
