#!/usr/bin/env bash

if [ -z $KAFKA_CONNECTOR ];then
  echo "KAFKA_CONNECTOR is not set !!!"
  exit 0
fi

SCRIPT=$(basename $0)
function usage(){
    echo -e "\nUSAGE: $SCRIPT config \n"
    exit 1
}

if [ $# -lt 1 ] ; then
   usage
fi


curl -X POST -i -H "Content-Type: application/json" -H "Accept: application/json" \
    --data @$1 \
    ${KAFKA_CONNECTOR}/connectors