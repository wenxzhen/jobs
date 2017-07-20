#!/usr/bin/env bash

SCRIPT=$(basename $0)
function usage(){
    echo -e "\nUSAGE: $SCRIPT <topic>\n"
    exit 1
}

if [ $# -lt 1 ] ; then
   usage
fi

export KAFKA_CLIENT_CONF=./consumer.properties
export KAFKA_LIBS_DIR=/data/1/usr/local/confluent/libs
export JAVA_OPTS=-Djava.security.auth.login.config=/home/kylin/demo/kafka_client.jaas


echo "Use config: "$KAFKA_CLIENT_CONF

export CLASSPATH=./kafka-clent.jar

for i in ${KAFKA_LIBS_DIR}/*.jar ; do
    CLASSPATH=$CLASSPATH:$i
done

java $JAVA_OPTS -cp $CLASSPATH ConsoleConsumer $1
