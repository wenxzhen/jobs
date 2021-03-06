#!/usr/bin/env bash

if [ -z $KAFKA_CONNECTOR ];then
  echo "KAFKA_CONNECTOR is not set !!!"
  exit 0
fi

SCRIPT=$(basename $0)
function usage(){
    echo -e "\nUSAGE: $SCRIPT connector-name \n"
    exit 1
}

if [ $# -lt 1 ] ; then
   usage
fi

curl -X PUT -i ${KAFKA_CONNECTOR}/connectors/$1/resume