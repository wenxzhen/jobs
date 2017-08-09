http://blog.cloudera.com/blog/2017/06/offset-management-for-apache-kafka-with-apache-spark-streaming/


An ingest pattern that we commonly see being adopted at Cloudera customers is Apache Spark Streaming applications which read data from Kafka. Streaming data continuously from Kafka has many benefits such as having the capability to gather insights faster. However, users must take into consideration management of Kafka offsets in order to recover their streaming application from failures. In this post, we will provide an overview of Offset Management and following topics.

* Storing offsets in external data stores
    * Checkpoints
    * HBase
    * ZooKeeper
    * Kafka
* Not managing offsets

# Overview of Offset Management
Spark Streaming integration with Kafka allows users to read messages from a single Kafka topic or multiple Kafka topics. A Kafka topic receives messages across a distributed set of partitions where they are stored. Each partition maintains the messages it has received in a sequential order where they are identified by an offset, also known as a position. Developers can take advantage of using offsets in their application to control the position of where their Spark Streaming job reads from, but it does require offset management.

Managing offsets is most beneficial to achieve data continuity over the lifecycle of the stream process. For example, upon shutting down the stream application or an unexpected failure, offset ranges will be lost unless persisted in a non-volatile data store. Further, without offsets of the partitions being read, the Spark Streaming job will not be able to continue processing data from where it had last left off.

![Alt text](Spark-Streaming-flow-for-offsets.png "Optional title")

The above diagram depicts the general flow for managing offsets in your Spark Streaming application. Offsets can be managed in several ways, but generally follow this common sequence of steps.
1. Upon initialization of the Direct DStream, a map of offsets for each topic’s partition can be specified of where the Direct DStream should start reading from for each partition.
   * The offsets specified are in the same location that step 4 below writes to.
2. The batch of messages can then be read and processed.
3. After processing, the results can be stored as well as offsets.
   * The dotted line around store results and commit offsets actions simply highlights a sequence of steps where users may want to further review if a special scenario of stricter delivery semantics are required. This may include review of idempotent operations or storing the results with their offsets in an atomic operation.
4. Lastly, any external durable data store such as HBase, Kafka, HDFS, and ZooKeeper are used to keep track of which messages have already been processed.

Different scenarios can be incorporated into the above steps depending upon business requirements. Spark’s programmatic flexibility allows users fine-grained control to store offsets before or after periodic phases of processing. Consider an application where the following is occurring: a Spark Streaming application is reading messages from Kafka, performing a lookup against HBase data to enrich or transform the messages and then posting the enriched messages to another topic or separate system (e.g. other messaging system, back to HBase, Solr, DBMS, etc.). In this case, we only consider the messages as processed when they are successfully posted to the secondary system.

# Storing Offsets Externally
In this section, we explore different options for persisting offsets externally in a durable data store.

For the approaches mentioned in this section, if using the spark-streaming-kafka-0-10 library, we recommend users to set `enable.auto.commit` to `false`. This configuration is only applicable to this version, and by setting `enable.auto.commit` to `true` means that offsets are committed automatically with a frequency controlled by the config `auto.commit.interval.ms`. In Spark Streaming, setting this to `true` commits the offsets to Kafka automatically when messages are read from Kafka which doesn’t necessarily mean that Spark has finished processing those messages. To enable precise control for committing offsets, set Kafka parameter `enable.auto.commit` to `false` and follow one of the options below.

## Spark Streaming checkpoints
Enabling Spark Streaming’s checkpoint is the simplest method for storing offsets, as it is readily available within Spark’s framework. Streaming checkpoints are purposely designed to save the state of the application, in our case to HDFS, so that it can be recovered upon failure.

Checkpointing the Kafka Stream will cause the offset ranges to be stored in the checkpoint. If there is a failure, the Spark Streaming application can begin reading the messages from the checkpoint offset ranges. However, Spark Streaming checkpoints are not recoverable across applications or Spark upgrades and hence not very reliable, especially if you are using this mechanism for a critical production application. We do not recommend managing offsets via Spark checkpoints.

## Storing Offsets in HBase
HBase can be used as an external data store to preserve offset ranges in a reliable fashion. By storing offset ranges externally, it allows Spark Streaming applications the ability to restart and replay messages from any point in time as long as the messages are still alive in Kafka.

With HBase’s generic design, the application is able to leverage the row key and column structure to handle storing offset ranges across multiple Spark Streaming applications and Kafka topics within the same table. In this example, each entry written to the table can be uniquely distinguished with a row key containing the topic name, consumer group id, and the Spark Streaming batchTime.milliSeconds. Although `batchTime.milliSeconds` isn’t required, it does provide insight to historical batches and the offsets which were processed. New records will accumulate in the table which we have configured in the below design to automatically expire after 30 days. Below is the HBase table DDL and structure.

```
## DDL
create 'stream_kafka_offsets', {NAME=>'offsets', TTL=>2592000}

## RowKey Layout
row:              <TOPIC_NAME>:<GROUP_ID>:<EPOCH_BATCHTIME_MS>
column family:    offsets
qualifier:        <PARTITION_ID>
value:            <OFFSET_ID>
```

For each batch of messages, `saveOffsets()` function is used to persist last read offsets for a given kafka topic in HBase.

```
/*
 Save offsets for each batch into HBase
*/
def saveOffsets(TOPIC_NAME:String,GROUP_ID:String,offsetRanges:Array[OffsetRange],
                hbaseTableName:String,batchTime: org.apache.spark.streaming.Time) ={
  val hbaseConf = HBaseConfiguration.create()
  hbaseConf.addResource("src/main/resources/hbase-site.xml")
  val conn = ConnectionFactory.createConnection(hbaseConf)
  val table = conn.getTable(TableName.valueOf(hbaseTableName))
  val rowKey = TOPIC_NAME + ":" + GROUP_ID + ":" +String.valueOf(batchTime.milliseconds)
  val put = new Put(rowKey.getBytes)
  for(offset <- offsetRanges){
    put.addColumn(Bytes.toBytes("offsets"),Bytes.toBytes(offset.partition.toString),
          Bytes.toBytes(offset.untilOffset.toString))
  }
  table.put(put)
  conn.close()
}
```

At the beginning of the streaming job, getLastCommittedOffsets() function is used to read the kafka topic offsets from HBase that were last processed when Spark Streaming application stopped. Function handles the following common scenarios while returning kafka topic partition offsets.

* Case 1: Streaming job is started for the first time. Function queries the zookeeper to find the number of partitions in a given topic. It then returns ‘0’ as the offset for all the topic partitions.

* Case 2: Long running streaming job had been stopped and new partitions are added to a kafka topic. Function queries the zookeeper to find the current number of partitions in a given topic. For all the old topic partitions, offsets are set to the latest offsets found in HBase. For all the new topic partitions, it returns ‘0’ as the offset.

* Case 3: Long running streaming job had been stopped and there are no changes to the topic partitions. In this case, the latest offsets found in HBase are returned as offsets for each topic partition.

When new partitions are added to a topic once the streaming application is started, only messages from the topic partitions that were detected during the start of the streaming application are ingested. For streaming job to read the messages from newly added topic partitions, job has to be restarted.

```
/* Returns last committed offsets for all the partitions of a given topic from HBase in  
following  cases.
*/
    
def getLastCommittedOffsets(TOPIC_NAME:String,GROUP_ID:String,hbaseTableName:String,
zkQuorum:String,zkRootDir:String,sessionTimeout:Int,connectionTimeOut:Int):Map[TopicPartition,Long] ={
 
  val hbaseConf = HBaseConfiguration.create()
  val zkUrl = zkQuorum+"/"+zkRootDir
  val zkClientAndConnection = ZkUtils.createZkClientAndConnection(zkUrl,
                                                sessionTimeout,connectionTimeOut)
  val zkUtils = new ZkUtils(zkClientAndConnection._1, zkClientAndConnection._2,false)
  val zKNumberOfPartitionsForTopic = zkUtils.getPartitionsForTopics(Seq(TOPIC_NAME)).get(TOPIC_NAME).toList.head.size
  zkClientAndConnection._1.close()
  zkClientAndConnection._2.close()
 
  //Connect to HBase to retrieve last committed offsets
  val conn = ConnectionFactory.createConnection(hbaseConf)
  val table = conn.getTable(TableName.valueOf(hbaseTableName))
  val startRow = TOPIC_NAME + ":" + GROUP_ID + ":" +
                                              String.valueOf(System.currentTimeMillis())
  val stopRow = TOPIC_NAME + ":" + GROUP_ID + ":" + 0
  val scan = new Scan()
  val scanner = table.getScanner(scan.setStartRow(startRow.getBytes).setStopRow(
                                                   stopRow.getBytes).setReversed(true))
  val result = scanner.next()
  var hbaseNumberOfPartitionsForTopic = 0 //Set the number of partitions discovered for a topic in HBase to 0
  if (result != null){
  //If the result from hbase scanner is not null, set number of partitions from hbase 
  to the  number of cells
    hbaseNumberOfPartitionsForTopic = result.listCells().size()
  }
 
val fromOffsets = collection.mutable.Map[TopicPartition,Long]()
 
  if(hbaseNumberOfPartitionsForTopic == 0){
    // initialize fromOffsets to beginning
    for (partition <- 0 to zKNumberOfPartitionsForTopic-1){
      fromOffsets += (new TopicPartition(TOPIC_NAME,partition) -> 0)
    }
  } else if(zKNumberOfPartitionsForTopic > hbaseNumberOfPartitionsForTopic){
  // handle scenario where new partitions have been added to existing kafka topic
    for (partition <- 0 to hbaseNumberOfPartitionsForTopic-1){
      val fromOffset = Bytes.toString(result.getValue(Bytes.toBytes("offsets"),
                                        Bytes.toBytes(partition.toString)))
      fromOffsets += (new TopicPartition(TOPIC_NAME,partition) -> fromOffset.toLong)
    }
    for (partition <- hbaseNumberOfPartitionsForTopic to zKNumberOfPartitionsForTopic-1){
      fromOffsets += (new TopicPartition(TOPIC_NAME,partition) -> 0)
    }
  } else {
  //initialize fromOffsets from last run
    for (partition <- 0 to hbaseNumberOfPartitionsForTopic-1 ){
      val fromOffset = Bytes.toString(result.getValue(Bytes.toBytes("offsets"),
                                        Bytes.toBytes(partition.toString)))
      fromOffsets += (new TopicPartition(TOPIC_NAME,partition) -> fromOffset.toLong)
    }
  }
  scanner.close()
  conn.close()
  fromOffsets.toMap
}
```

Once we have the last committed offsets (fromOffsets in this example), we can create a Kafka Direct DStream.

```
val fromOffsets= getLastCommittedOffsets(topic,consumerGroupID,hbaseTableName,zkQuorum,
                                        zkKafkaRootDir,zkSessionTimeOut,zkConnectionTimeOut)
 
val inputDStream = KafkaUtils.createDirectStream[String,String](ssc,PreferConsistent,
                           Assign[String, String](fromOffsets.keys,kafkaParams,fromOffsets))
```

After completing the processing of messages in a Kafka DStream, we can store topic partition offsets by calling `saveOffsets()`.

```
/*
For each RDD in a DStream apply a map transformation that processes the message.
*/
inputDStream.foreachRDD((rdd,batchTime) => {
  val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges
  offsetRanges.foreach(offset => println(offset.topic,offset.partition, offset.fromOffset,
                        offset.untilOffset))
  val newRDD = rdd.map(message => processMessage(message))
  newRDD.count()
  saveOffsets(topic,consumerGroupID,offsetRanges,hbaseTableName,batchTime) 
})
```

You can inspect the stored offsets in HBase for various topics and consumer groups as shown below.
```
hbase(main):001:0> scan 'stream_kafka_offsets', {REVERSED => true}
ROW                                                COLUMN+CELL
 kafkablog2:groupid-1:1497628830000                column=offsets:0, timestamp=1497628832448, value=285
 kafkablog2:groupid-1:1497628830000                column=offsets:1, timestamp=1497628832448, value=285
 kafkablog2:groupid-1:1497628830000                column=offsets:2, timestamp=1497628832448, value=285
 kafkablog2:groupid-1:1497628770000                column=offsets:0, timestamp=1497628773773, value=225
 kafkablog2:groupid-1:1497628770000                column=offsets:1, timestamp=1497628773773, value=225
 kafkablog2:groupid-1:1497628770000                column=offsets:2, timestamp=1497628773773, value=225
 kafkablog1:groupid-2:1497628650000                column=offsets:0, timestamp=1497628653451, value=165
 kafkablog1:groupid-2:1497628650000                column=offsets:1, timestamp=1497628653451, value=165
 kafkablog1:groupid-2:1497628650000                column=offsets:2, timestamp=1497628653451, value=165
 kafkablog1:groupid-1:1497628530000                column=offsets:0, timestamp=1497628533108, value=120
 kafkablog1:groupid-1:1497628530000                column=offsets:1, timestamp=1497628533108, value=120
 kafkablog1:groupid-1:1497628530000                column=offsets:2, timestamp=1497628533108, value=120
4 row(s) in 0.5030 seconds
 
hbase(main):002:0>
```

## Storing Offsets in ZooKeeper
Users can store offset ranges in ZooKeeper, which can similarly provide a reliable method for starting stream processing on a Kafka stream where it had last left off.

In this scenario, on start-up, the Spark Streaming job will retrieve the latest processed offsets from ZooKeeper for each topic’s partition. If a new partition is found which was not previously managed in ZooKeeper, its latest processed offset is defaulted to start from the beginning. After processing each batch, the users’ have the capability to either store the first or last offset processed. Additionally, the znode location in which the offset is stored in ZooKeeper uses the same format as the old Kafka consumer API. Therefore, any tools that are built to track or monitor Kafka offsets stored in ZooKeeper still work.

Initialize ZooKeeper connection for retrieving and storing offsets to ZooKeeper.

```
val zkClientAndConnection = ZkUtils.createZkClientAndConnection(zkUrl, sessionTimeout, connectionTimeout)
val zkUtils = new ZkUtils(zkClientAndConnection._1, zkClientAndConnection._2, false)
```

Method for retrieving the last offsets stored in ZooKeeper of the consumer group and topic list.

```
def readOffsets(topics: Seq[String], groupId:String):
 Map[TopicPartition, Long] = {
 
 val topicPartOffsetMap = collection.mutable.HashMap.empty[TopicPartition, Long]
 val partitionMap = zkUtils.getPartitionsForTopics(topics)
 
 // /consumers/<groupId>/offsets/<topic>/
 partitionMap.foreach(topicPartitions => {
   val zkGroupTopicDirs = new ZKGroupTopicDirs(groupId, topicPartitions._1)
   topicPartitions._2.foreach(partition => {
     val offsetPath = zkGroupTopicDirs.consumerOffsetDir + "/" + partition
 
     try {
       val offsetStatTuple = zkUtils.readData(offsetPath)
       if (offsetStatTuple != null) {
         LOGGER.info("retrieving offset details - topic: {}, partition: {}, offset: {}, node path: {}", Seq[AnyRef](topicPartitions._1, partition.toString, offsetStatTuple._1, offsetPath): _*)
 
         topicPartOffsetMap.put(new TopicPartition(topicPartitions._1, Integer.valueOf(partition)),
           offsetStatTuple._1.toLong)
       }
 
     } catch {
       case e: Exception =>
         LOGGER.warn("retrieving offset details - no previous node exists:" + " {}, topic: {}, partition: {}, node path: {}", Seq[AnyRef](e.getMessage, topicPartitions._1, partition.toString, offsetPath): _*)
 
         topicPartOffsetMap.put(new TopicPartition(topicPartitions._1, Integer.valueOf(partition)), 0L)
     }
   })
 })
 
 topicPartOffsetMap.toMap
}
```

Initialization of Kafka Direct Dstream with the specific offsets to start processing from.

```
val inputDStream = KafkaUtils.createDirectStream(ssc, PreferConsistent, ConsumerStrategies.Subscribe[String,String](topics, kafkaParams, fromOffsets))
```

Method for persisting a recoverable set of offsets to ZooKeeper.

Note: The offsetPath is a ZooKeeper location represented as, /consumers/[groupId]/offsets/topic/[partitionId], that stores the value of the offset.

```
def persistOffsets(offsets: Seq[OffsetRange], groupId: String, storeEndOffset: Boolean): Unit = {
 offsets.foreach(or => {
   val zkGroupTopicDirs = new ZKGroupTopicDirs(groupId, or.topic);
 
   val acls = new ListBuffer[ACL]()
   val acl = new ACL
   acl.setId(ANYONE_ID_UNSAFE)
   acl.setPerms(PERMISSIONS_ALL)
   acls += acl
 
   val offsetPath = zkGroupTopicDirs.consumerOffsetDir + "/" + or.partition;
   val offsetVal = if (storeEndOffset) or.untilOffset else or.fromOffset
   zkUtils.updatePersistentPath(zkGroupTopicDirs.consumerOffsetDir + "/"
     + or.partition, offsetVal + "", JavaConversions.bufferAsJavaList(acls))
 
   LOGGER.debug("persisting offset details - topic: {}, partition: {}, offset: {}, node path: {}", Seq[AnyRef](or.topic, or.partition.toString, offsetVal.toString, offsetPath): _*)
 })
}
```

## Kafka Itself
With Cloudera Distribution of Apache Spark 2.1.x, spark-streaming-kafka-0-10 uses the new consumer api that exposes commitAsync API. Using the commitAsync API the consumer will commit the offsets to Kafka after you know that your output has been stored. The new consumer api commits offsets back to Kafka uniquely based on the consumer’s group.id.

Persist Offsets in Kafka

```
stream.foreachRDD { rdd =>
  val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges
 
  // some time later, after outputs have completed
  stream.asInstanceOf[CanCommitOffsets].commitAsync(offsetRanges)
}
```

Learn more about this at – http://spark.apache.org/docs/latest/streaming-kafka-0-10-integration.html#kafka-itself

Note: commitAsync() is part of the kafka-0-10 version of Spark Streaming and Kafka Integration. As noted in Spark documentation, this integration is still experimental and API can potentially change.


## Other Approaches
It is worth mentioning that you can also store offsets in a storage system like HDFS. Storing offsets in HDFS is a less popular approach compared to the above options as HDFS has a higher latency compared to other systems like ZooKeeper and HBase. Additionally, writing offsetRanges for each batch in HDFS can lead to a small files problem if not managed properly.

## Not managing offsets
Managing offsets is not always a requirement for Spark Streaming applications. One example where it may not be required is when users may only need current data of the streaming application, such as a live activity monitor. In these instances where you don’t require to manage the offsets, you can either set the Kafka parameter `auto.offset.reset` to either `largest` or `smallest` if using the old Kafka consumer or earliest or latest if using the new Kafka consumer.

When you restart the job with `auto.offset.reset` set to `smallest` (or `earliest`), it will replay the whole log from the beginning (smallest offset) of your topic. With this setting all the messages that are still retained in the topic will be read. This might lead to duplicates depending on your Kafka topic retention period.

Alternatively, if you restart the Spark Streaming job with `auto.offset.reset` to `largest` (or `latest`), it reads the messages from latest offset of each Kafka topic partition. This might lead to loss of some messages. Depending on how critical your Spark Streaming application is and the delivery semantics it require, this might be a viable approach.