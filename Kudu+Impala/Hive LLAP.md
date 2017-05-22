# 全称： Live Long and Process (LLAP)

在hive2.0中添加了LLAP功能（HIVE-7926），文档jira 是HIVE-9850。

配置LLAP可以参考 Configuration Properties. 中的llap部分



## 概览
在最近几年，hive的速度有了显著的提升，这要感谢社区贡献的多种特征和提升其中包括Tez和CBO，下边是我们要把hive带到更高的层次：
* 异步IO
* 预拉取和缓存列快
* 多线程JIT友好的操作流

LLAP提供了一个高级的执行模式，它包括一个长久存活的守护程序去代替了和HDFS datanode的直接交互 和一个紧密集成的DAG框架。这个守护程序中加入了缓存、预抓取、查询过程和访问控制等功能。短小的查询由守护程序执行，大的重的操作由yarn的container执行。
和datanode相似，llap守护程序可以被其他程序使用，特别是一个以文件为中的展示数据关系的视图。这个是守护程序也开发了API让其它程序来集成它。
最后，一个很好的列层的访问授权，hive中主流采用的关键需求。
下面这个图展示的了LLAP 在Tez的执行。初始化阶段的查询放在了LLAP，大的shuffle在他们的container中执行，多个查询和应用可以同时访问LLAP.


## 持久的守护程序
为了实现缓存、JIT优化和减少启动时间，我们要在集群的节点上运行守护进程，它将处理IO、，缓存、查询段执行。
这些节点将是无状态的  任何对llap节点的请求必须包含本地数据和元数据。他将在本地和远程执行，本地化是请求者的责任（YARN）
可恢复和弹性的 失败和恢复被简化，因为任何数据节点可以被作为任何阶段的输入数据使用。Tez AM可以很简单的返回集群上的失败阶段。
节点间可以交流  LLAP节点可以分享数据（例如 抓取的分区、广播的阶段） ，这将是Tez中用同样的机制来实现的。
* 执行引擎
LLAP和现在已经存在的hive一起工作来提供可以伸缩、多样性的hive，他是加强hive而不是取代hive。
* 守护程序是可选的
外部的协调和执行引擎  LLAP不是执行引擎，它依赖于执行引擎（Tez） 不打算支持MR
* 部分执行
资源管理  Yarn container 授权给LLAP

## 请求分段执行
LLAP能执行如下分段：ilters, projections, data transformations, partial aggregates, sorting, bucketing, hash joins/semi-joins
平行执行 节点允许从不同查询不同session来的查询段水平执行
接口 
I/O
守护进程将摆脱I/0， 将压缩格式转移到单独的线程。数据准备好后被送去执行，所以当现在正在执行的时候可以准备下一个数据。
多种文件格式
谓词和 bloom filters
## 缓存
守护进程会缓存输入文件和数据的元数据。元数据和索引信息将会被缓存即使现在数据还没被缓存。元数据存在当前进程的java类里面，缓存数据被存储在格式化的IO分片
* 收回政策  应用在分析表的扫描的工作压力
* 缓存粒度 数据缓存的单元是列式的


原文地址： https://cwiki.apache.org/confluence/display/Hive/LLAP