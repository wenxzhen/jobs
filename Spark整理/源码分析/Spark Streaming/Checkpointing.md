# Checkpointing #
`Checkpointing` is a process of writing received records (by means of input dstreams) at
`checkpoint intervals` to a `highly-available HDFS-compatible storage`. It allows creating faulttolerant
stream processing pipelines so when a failure occurs input dstreams can restore
the before-failure streaming state and continue stream processing (as if nothing had
happened).
DStreams can checkpoint input data at specified time intervals.

# Marking StreamingContext as Checkpointed #
You use StreamingContext.checkpoint method to set up a HDFS-compatible checkpoint
directory where checkpoint data will be persisted, as follows:

  `ssc.checkpoint("_checkpoint")`

# Recreating StreamingContext from Checkpoint #
You can create a StreamingContext from a checkpoint directory, i.e. recreate a fully-working
StreamingContext as recorded in the last valid checkpoint file that was written to the
checkpoint directory.

|Note   | Desc |
|--------|----------------------------------------|
|Warning | You must not create input dstreams using a StreamingContext that has been recreated from checkpoint. Otherwise, you will not start the StreamingContext at all.|

The following Scala code demonstrates how to use the checkpoint directory `_checkpoint` to
(re)create the StreamingContext or create one from scratch.

```java
  val appName = "Recreating StreamingContext from Checkpoint"
  val sc = new SparkContext("local[*]", appName, new SparkConf())
  val checkpointDir = "_checkpoint"
  def createSC(): StreamingContext = {
  val ssc = new StreamingContext(sc, batchDuration = Seconds(5))
  // NOTE: You have to create dstreams inside the method
  // See http://stackoverflow.com/q/35090180/1305344
  // Create constant input dstream with the RDD
  val rdd = sc.parallelize(0 to 9)
  import org.apache.spark.streaming.dstream.ConstantInputDStream
  val cis = new ConstantInputDStream(ssc, rdd)
  // Sample stream computation
  cis.print
  ssc.checkpoint(checkpointDir)
  ssc
  }
  val ssc = StreamingContext.getOrCreate(checkpointDir, createSC)
  // Start streaming processing
  ssc.start
```

# DStreamCheckpointData
`DStreamCheckpointData` works with a single dstream. An instance of `DStreamCheckpointData`
is created when a dstream is.
```java
Dstream.Scala
private[streaming] val checkpointData = new DStreamCheckpointData(this)
```

It tracks checkpoint data in the internal `data` registry that `records batch time and the
checkpoint data at that time`. The internal checkpoint data can be anything that a dstream
wants to checkpoint. DStreamCheckpointData returns the registry when
`currentCheckpointFiles` method is called.

```java
class DStreamCheckpointData[T: ClassTag](dstream: DStream[T])
  extends Serializable with Logging {

  protected val data = new HashMap[Time, AnyRef]()

  // Mapping of the batch time to the checkpointed RDD file of that time
  @transient private var timeToCheckpointFile = new HashMap[Time, String];

  @transient private var fileSystem: FileSystem = null;

  protected[streaming] def currentCheckpointFiles = data.asInstanceOf[HashMap[Time, String]]

  /**
   * Updates the checkpoint data of the DStream. This gets called every time
   * the graph checkpoint is initiated. Default implementation records the
   * checkpoint files at which the generated RDDs of the DStream have been saved.
   */
  def update(time: Time) {

    // Get the checkpointed RDDs from the generated RDDs
    val checkpointFiles = dstream.generatedRDDs.filter(_._2.getCheckpointFile.isDefined)
                                       .map(x => (x._1, x._2.getCheckpointFile.get))
    logDebug("Current checkpoint files:\n" + checkpointFiles.toSeq.mkString("\n"))

    // Add the checkpoint files to the data to be serialized
    if (!checkpointFiles.isEmpty) {
      currentCheckpointFiles.clear()
      currentCheckpointFiles ++= checkpointFiles
      // Add the current checkpoint files to the map of all checkpoint files
      // This will be used to delete old checkpoint files
      timeToCheckpointFile ++= currentCheckpointFiles
      // Remember the time of the oldest checkpoint RDD in current state
      timeToOldestCheckpointFileTime(time) = currentCheckpointFiles.keys.min(Time.ordering)
    }
  }

  /**
   * Cleanup old checkpoint data. This gets called after a checkpoint of `time` has been
   * written to the checkpoint directory.
   */
  def cleanup(time: Time) : Unit

  /**
   * Restore the checkpoint data. This gets called once when the DStream graph
   * (along with its output DStreams) is being restored from a graph checkpoint file.
   * Default implementation restores the RDDs from their checkpoint files.
   */
  def restore() {
    currentCheckpointFiles.foreach {
      case(time, file) =>
        logInfo("Restoring checkpointed RDD for time " + time + " from file '" + file + "'")
        dstream.generatedRDDs += ((time, dstream.context.sparkContext.checkpointFile[T](file)))
    }
  }

  @throws(classOf[IOException])
  private def writeObject(oos: ObjectOutputStream): Unit

  @throws(classOf[IOException])
  private def readObject(ois: ObjectInputStream): Unit
}
```

# Checkpoint #


> Checkpoint class is written to a persistent storage (aka serialized) using
`CheckpointWriter.write` method and read back (aka deserialize) using
`Checkpoint.deserialize`.

> Initial checkpoint is the checkpoint a `StreamingContext` was started with.

It is merely a collection of the settings of the current streaming `runtime environment` that is
supposed to recreate the environment after it goes down due to a failure or when the
streaming context is stopped immediately.
It collects the settings from the input StreamingContext `(and indirectly from the
corresponding JobScheduler and SparkContext`):


```java
private[streaming]
class Checkpoint(ssc: StreamingContext, val checkpointTime: Time)
  extends Logging with Serializable {
  val master = ssc.sc.master
  val framework = ssc.sc.appName
  val jars = ssc.sc.jars
  val graph = ssc.graph
  val checkpointDir = ssc.checkpointDir
  val checkpointDuration = ssc.checkpointDuration
  val pendingTimes = ssc.scheduler.getPendingTimes().toArray
  val sparkConfPairs = ssc.conf.getAll

  def createSparkConf(): SparkConf = {
    // Reload properties for the checkpoint application since user wants to set a reload property
    // or spark had changed its value and user wants to set it back.
    val propertiesToReload = List(
      "spark.yarn.app.id",
      "spark.yarn.app.attemptId",
      "spark.driver.host",
      "spark.driver.port",
      "spark.master",
      "spark.yarn.keytab",
      "spark.yarn.principal",
      "spark.ui.filters")

    val newSparkConf = new SparkConf(loadDefaults = false).setAll(sparkConfPairs)
      .remove("spark.driver.host")
      .remove("spark.driver.port")
    val newReloadConf = new SparkConf(loadDefaults = true)
    propertiesToReload.foreach { prop =>
      newReloadConf.getOption(prop).foreach { value =>
        newSparkConf.set(prop, value)
      }
    }

    // Add Yarn proxy filter specific configurations to the recovered SparkConf
    val filter = "org.apache.hadoop.yarn.server.webproxy.amfilter.AmIpFilter"
    val filterPrefix = s"spark.$filter.param."
    newReloadConf.getAll.foreach { case (k, v) =>
      if (k.startsWith(filterPrefix) && k.length > filterPrefix.length) {
        newSparkConf.set(k, v)
      }
    }

    newSparkConf
  }

  def validate() {
    assert(master != null, "Checkpoint.master is null")
    assert(framework != null, "Checkpoint.framework is null")
    assert(graph != null, "Checkpoint.graph is null")
    assert(checkpointTime != null, "Checkpoint.checkpointTime is null")
    logInfo(s"Checkpoint for time $checkpointTime validated")
  }
}
```
org.apache.spark.streaming.StreamingContext 首次启动，执行第一次检查点
```java
/**
  * Start the execution of the streams.
  *
  * @throws IllegalStateException if the StreamingContext is already stopped.
  */
 def start(): Unit = synchronized {
   state match {
     case INITIALIZED =>
       startSite.set(DStream.getCreationSite())
       StreamingContext.ACTIVATION_LOCK.synchronized {
         StreamingContext.assertNoOtherContextIsActive()
         try {
           validate()
           ………………………………
           state = StreamingContextState.ACTIVE
         } catch {
           ………………………………
         }
         StreamingContext.setActiveContext(this)
       }  
   }
 }
 private def validate() {
   assert(graph != null, "Graph is null")
   graph.validate()
   ……………………
   // Verify whether the DStream checkpoint is serializable
   if (isCheckpointingEnabled) {
     val checkpoint = new Checkpoint(this, Time(0))
     try {
       Checkpoint.serialize(checkpoint, conf)
     } catch {
       ……………………
     }
   }

   if (Utils.isDynamicAllocationEnabled(sc.conf) ||
       ExecutorAllocationManager.isDynamicAllocationEnabled(conf)) {
      ……………………
   }
 }
```
JobGenerator定时产生Job，Job执行完成后再次执行CheckPoint
```java
class JobGenerator(jobScheduler: JobScheduler) extends Logging {
  private val ssc = jobScheduler.ssc
  private val conf = ssc.conf
  private val graph = ssc.graph
  private val timer = new RecurringTimer(clock, ssc.graph.batchDuration.milliseconds,
    longTime => eventLoop.post(GenerateJobs(new Time(longTime))), "JobGenerator")
  // eventLoop is created when generator starts.
  // This not being null means the scheduler has been started and not stopped
  private var eventLoop: EventLoop[JobGeneratorEvent] = null
  // last batch whose completion,checkpointing and metadata cleanup has been completed
  private var lastProcessedBatch: Time = null

  /** Start generation of jobs */
  def start(): Unit = synchronized {
    if (eventLoop != null) return // generator has already been started
    // Call checkpointWriter here to initialize it before eventLoop uses it to avoid a deadlock.
    // See SPARK-10125
    checkpointWriter
    eventLoop = new EventLoop[JobGeneratorEvent]("JobGenerator") {
      override protected def onReceive(event: JobGeneratorEvent): Unit = processEvent(event)

      override protected def onError(e: Throwable): Unit = {
        jobScheduler.reportError("Error in job generator", e)
      }
    }
    eventLoop.start()
    if (ssc.isCheckpointPresent) {
      restart()
    } else {
      startFirstTime()
    }
  }
  /** Processes all events */
  private def processEvent(event: JobGeneratorEvent) {
    logDebug("Got event " + event)
    event match {
      case GenerateJobs(time) => generateJobs(time)
      case ClearMetadata(time) => clearMetadata(time)
      case DoCheckpoint(time, clearCheckpointDataLater) =>
        doCheckpoint(time, clearCheckpointDataLater)
      case ClearCheckpointData(time) => clearCheckpointData(time)
    }
  }
  /** Generate jobs and perform checkpointing for the given `time`.  */
  private def generateJobs(time: Time) {
    // Checkpoint all RDDs marked for checkpointing to ensure their lineages are
    // truncated periodically. Otherwise, we may run into stack overflows (SPARK-6847).
    ssc.sparkContext.setLocalProperty(RDD.CHECKPOINT_ALL_MARKED_ANCESTORS, "true")
    Try {
      jobScheduler.receiverTracker.allocateBlocksToBatch(time) // allocate received blocks to batch
      graph.generateJobs(time) // generate jobs using allocated block
    } match {
      case Success(jobs) =>
        val streamIdToInputInfos = jobScheduler.inputInfoTracker.getInfo(time)
        jobScheduler.submitJobSet(JobSet(time, jobs, streamIdToInputInfos))
      case Failure(e) =>
        jobScheduler.reportError("Error generating jobs for time " + time, e)
        PythonDStream.stopStreamingContextIfPythonProcessIsDead(e)
    }
    eventLoop.post(DoCheckpoint(time, clearCheckpointDataLater = false))
  }
  /** Perform checkpoint for the give `time`. */
  private def doCheckpoint(time: Time, clearCheckpointDataLater: Boolean) {
    if (shouldCheckpoint && (time - graph.zeroTime).isMultipleOf(ssc.checkpointDuration)) {
      logInfo("Checkpointing graph for time " + time)
      ssc.graph.updateCheckpointData(time)
      checkpointWriter.write(new Checkpoint(ssc, time), clearCheckpointDataLater)
    }
  }
}
```
