#! /usr/bin/bash

SCRIPT=$(basename $0)
function print_usage(){
   echo "Usage: $SCRIPT  <hdfs_path>"
   exit 0
}

if [ $# != 1 ]; then
  print_usage
fi

hdfs_path=$1

timestmp=`date  +%s`

hdfs dfs -ls $hdfs_path

hdfs dfs -ls $hdfs_path | awk ' /^-/ && $5==0 { print "hdfs dfs -rm "$8 }' > /tmp/$timestmp.sh

cat /tmp/$timestmp.sh

sh /tmp/$timestmp.sh

rm /tmp/$timestmp.sh
