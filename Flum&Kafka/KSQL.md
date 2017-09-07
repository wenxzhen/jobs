# 启动Kafka
```
$ bin/kafka-server-start.sh config/server.properties
$ bin/zookeeper-server-start.sh config/zookeeper.properties
```
# 下载 启动 Ksql 
```
$ git clone git@github.com:confluentinc/ksql.git
$ cd ksql
$ mvn clean compile install -DskipTests
$ bin/ksql-server-start config/ksqlserver.properties
$ bin/ksql-cli remote http://localhost:8080
                       ======================================
                       =      _  __ _____  ____  _          =
                       =     | |/ // ____|/ __ \| |         =
                       =     | ' /| (___ | |  | | |         =
                       =     |  <  \___ \| |  | | |         =
                       =     | . \ ____) | |__| | |____     =
                       =     |_|\_\_____/ \___\_\______|    =
                       =                                    =
                       =   Streaming SQL Engine for Kafka   =
Copyright 2017 Confluent Inc.                         

CLI v0.1, Server v0.1 located at http://localhost:8080

Having trouble? Type 'help' (case-insensitive) for a rundown of how things work!
```

# 生成模拟数据
```
java -jar ksql-examples/target/ksql-examples-0.1-SNAPSHOT-standalone.jar \
	bootstrap-server=192.168.6.145:9092 \
    quickstart=pageviews format=delimited topic=pageviews maxInterval=10000

java -jar ksql-examples/target/ksql-examples-0.1-SNAPSHOT-standalone.jar \
	bootstrap-server=192.168.6.145:9092 \
    quickstart=users format=delimited topic=users maxInterval=10000

bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic pageviews --from-beginning
bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic users --from-beginning
```
# DEMO
```
ksql> CREATE STREAM pageviews_original (viewtime bigint, userid varchar, pageid varchar) WITH (kafka_topic='pageviews', value_format='DELIMITED');

 Message        
----------------
 Stream created 
ksql> DESCRIBE pageviews_original;

 Field    | Type            
----------------------------
 ROWTIME  | BIGINT          
 ROWKEY   | VARCHAR(STRING) 
 VIEWTIME | BIGINT          
 USERID   | VARCHAR(STRING) 
 PAGEID   | VARCHAR(STRING) 

ksql> CREATE TABLE users_original (registertime bigint, gender varchar, regionid varchar, userid varchar) WITH (kafka_topic='users', value_format='DELIMITED');

 Message       
---------------
 Table created 
ksql> DESCRIBE users_original;

 Field        | Type            
--------------------------------
 ROWTIME      | BIGINT          
 ROWKEY       | VARCHAR(STRING) 
 REGISTERTIME | BIGINT          
 GENDER       | VARCHAR(STRING) 
 REGIONID     | VARCHAR(STRING) 
 USERID       | VARCHAR(STRING) 
ksql> 

```