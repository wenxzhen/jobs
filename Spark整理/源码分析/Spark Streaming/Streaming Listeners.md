# Streaming Listeners #
Streaming listeners are listeners interested in streaming events like batch submitted,
started or completed.
Streaming listeners implement           `org.apache.spark.streaming.scheduler.StreamingListener`
listener interface and process `StreamingListenerEvent` events.
The following streaming listeners are available in Spark Streaming:
* StreamingJobProgressListener
* RateController
