DStreamGraph (is a final helper class that) `manages input and output dstreams`. It also
holds `zero` time for the other components that marks the time when it was started.

DStreamGraph maintains the collections of `InputDStream` instances (as inputStreams ) and
`output DStream` instances (as outputStreams ), but, more importantly, `it generates streaming
jobs for output streams for a batch (time)`.


```java

final private[streaming] class DStreamGraph extends Serializable with Logging {

  private val inputStreams = new ArrayBuffer[InputDStream[_]]()
  private val outputStreams = new ArrayBuffer[DStream[_]]()

  var rememberDuration: Duration = null
  var checkpointInProgress = false

  var zeroTime: Time = null
  var startTime: Time = null
  var batchDuration: Duration = null

  def start(time: Time) {
    this.synchronized {
      require(zeroTime == null, "DStream graph computation already started")
      zeroTime = time
      startTime = time
      outputStreams.foreach(_.initialize(zeroTime))
      outputStreams.foreach(_.remember(rememberDuration))
      outputStreams.foreach(_.validateAtStart)
      inputStreams.par.foreach(_.start())
    }
  }

  def generateJobs(time: Time): Seq[Job] = {
    logDebug("Generating jobs for time " + time)
    val jobs = this.synchronized {
      outputStreams.flatMap { outputStream =>
        val jobOption = outputStream.generateJob(time)
        jobOption.foreach(_.setCallSite(outputStream.creationSite))
        jobOption
      }
    }
    logDebug("Generated " + jobs.length + " jobs for time " + time)
    jobs
  }
}
```
