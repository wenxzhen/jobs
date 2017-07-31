#!/usr/bin/env bash

if [ -z $KAFKA_CONNECTOR ];then
  echo "KAFKA_CONNECTOR is not set !!!"
  exit 0
fi

curl -X GET -i ${KAFKA_CONNECTOR}/connectors