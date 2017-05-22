jmx可以将JVM内部的信息暴露出来，但是要获取那些jvm的内部信息，就还需要自己写java程序调用jmx接口去获取数据，并按照某种格式发送到其他地方（如监控程序Graphite,Zabbix等）。这时jmxtrans就派上用场了，jmxtrans的作用是自动去jvm中获取所需要的jmx数据，并按照某种格式（json文件配置格式）输出到其他应用程序。

# Kakfa配置
kafka的具体配置安装就不在本文具体描述了，在这里只需要添加 jmx端口配置即可
```
$ cd $KAFKA_HOME
$ export JMX_PORT=9999  ##或者 将 export JMX_PORT=9999 写入到 bin/zookeeper-server-start.sh
# 启动zookeeper
$ bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
# 启动 kafka
$ bin/kafka-server-start.sh -daemon config/server.properties
# 启动 kafka以后查看 jmx是否生效
$ jps -mlv | grep Kafka
60524 kafka.Kafka config/server.properties -Xmx1G -Xms1G -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+DisableExplicitGC -Djava.awt.headless=true -Xloggc:/home/hadoop/kafka_2.10-0.10.0.0/bin/../logs/kafkaServer-gc.log -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=9999 -Dkafka.logs.dir=/home/hadoop/kafka_2.10-0.10.0.0/bin/../logs -Dlog4j.configuration=file:bin/../config/log4j.properties
```

# Jmxtrans 安装
Jmxtrans 安装也特别简单，从官网下载安装包，根据平台不同，可以选择对应的版本，例如：rpm、Debian，这里我们下载 tar.gz 包
```
$ wget http://central.maven.org/maven2/org/jmxtrans/jmxtrans/264/jmxtrans-264-dist.tar.gz
$ tar -xzvf jmxtrans-264-dist.tar.gz 
$ cd jmxtrans-264
$ vi  kafka.json 
{
  "servers" : [ {
    "port" : "9999",  ## kafka jmx端口
    "host" : "192.168.76.132", ## kafka 主机ip
    "queries" : [ 
    {
      "outputWriters" : [ {  ## 将 jmx信息输出到 graphite
        "@class" : "com.googlecode.jmxtrans.model.output.GraphiteWriterFactory",
          "port" : 2003,
          "host" : "192.168.25.30",
          "rootPrefix" : "kafka"
      } ],
      "obj" : "kafka.server:type=BrokerTopicMetrics,name=BytesOutPerSec",
      "resultAlias": "TopicMetrics.BytesOutPerSec",
      "attr" : [ "Count","OneMinuteRate", "FiveMinuteRate", "FifteenMinuteRate" ]
    },
    {
      "outputWriters" : [ {
        "@class" : "com.googlecode.jmxtrans.model.output.GraphiteWriterFactory",
          "port" : 2003,
          "host" : "192.168.25.30",
          "rootPrefix" : "kafka"
      } ],
      "obj" : "kafka.server:type=BrokerTopicMetrics,name=BytesInPerSec",
      "resultAlias": "TopicMetrics.BytesInPerSec",
      "attr" : [ "Count","OneMinuteRate", "FiveMinuteRate", "FifteenMinuteRate" ]
    },

    {
      "outputWriters" : [ {
        "@class" : "com.googlecode.jmxtrans.model.output.GraphiteWriterFactory",
          "port" : 2003,
          "host" : "192.168.25.30",
          "rootPrefix" : "kafka"
      } ],
      "obj" : "kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec",
      "resultAlias": "TopicMetrics.MessagesInPerSec",
      "attr" : [ "Count","OneMinuteRate", "FiveMinuteRate", "FifteenMinuteRate" ]
    },
    {
      "outputWriters" : [ {
        "@class" : "com.googlecode.jmxtrans.model.output.GraphiteWriterFactory",
          "port" : 2003,
          "host" : "192.168.25.30",
          "rootPrefix" : "kafka"
      } ],
      "obj" : "java.lang:type=Memory",
      "resultAlias": "Memory",
      "attr" : [ "HeapMemoryUsage","NonHeapMemoryUsage" ]
    } ],
    "numQueryThreads" : 4
  } ]
}

# 启动 jmxtrans
$ bin/jmxtrans.sh start kafka.json

```

