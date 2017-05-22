```java
// RDDs generated, marked as private[streaming] so that testsuites can access it
@transient
private[streaming] var generatedRDDs = new HashMap[Time, RDD[T]]()
/**
 * Generate a SparkStreaming job for the given time. This is an internal method that
 * should not be called directly. This default implementation creates a job
 * that materializes the corresponding RDD. Subclasses of DStream may override this
 * to generate their own jobs.
 */
private[streaming] def generateJob(time: Time): Option[Job] = {
  getOrCompute(time) match {
    case Some(rdd) =>
      val jobFunc = () => {
        val emptyFunc = { (iterator: Iterator[T]) => {} }
        context.sparkContext.runJob(rdd, emptyFunc)
      }
      Some(new Job(time, jobFunc))
    case None => None
  }
}

  /**
 * Get the RDD corresponding to the given time; either retrieve it from cache
 * or compute-and-cache it.
 */
private[streaming] final def getOrCompute(time: Time): Option[RDD[T]] = {
  // If RDD was already generated, then retrieve it from HashMap,
  // or else compute the RDD
  generatedRDDs.get(time).orElse {
    // Compute the RDD if time is valid (e.g. correct time in a sliding window)
    // of RDD generation, else generate nothing.
    if (isTimeValid(time)) {

      val rddOption = createRDDWithLocalProperties(time, displayInnerRDDOps = false) {
        // Disable checks for existing output directories in jobs launched by the streaming
        // scheduler, since we may need to write output to an existing directory during checkpoint
        // recovery; see SPARK-4835 for more details. We need to have this call here because
        // compute() might cause Spark jobs to be launched.
        PairRDDFunctions.disableOutputSpecValidation.withValue(true) {
          compute(time)
        }
      }

      rddOption.foreach { case newRDD =>
        // Register the generated RDD for caching and checkpointing
        if (storageLevel != StorageLevel.NONE) {
          newRDD.persist(storageLevel)
          logDebug(s"Persisting RDD ${newRDD.id} for time $time to $storageLevel")
        }
        if (checkpointDuration != null && (time - zeroTime).isMultipleOf(checkpointDuration)) {
          newRDD.checkpoint()
          logInfo(s"Marking RDD ${newRDD.id} for time $time for checkpointing")
        }
        generatedRDDs.put(time, newRDD)
      }
      rddOption
    } else {
      None
    }
  }
}
```

## RDD生成和运算的调用栈
* org.apache.spark.streaming.scheduler.JobGenerator#eventLoop
* org.apache.spark.streaming.scheduler.JobGenerator#processEvent
* org.apache.spark.streaming.scheduler.JobGenerator#generateJobs
* org.apache.spark.streaming.DStreamGraph#generateJobs
* org.apache.spark.streaming.dstream.DStream#generateJob
* org.apache.spark.streaming.dstream.DStream#getOrCompute


## submitJobSet为逻辑提交，并未参与RDD的实际计算
org.apache.spark.streaming.scheduler.JobScheduler#submitJobSet
