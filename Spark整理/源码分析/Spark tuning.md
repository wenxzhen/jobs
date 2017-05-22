# Tuning
## Memory Management Overview
Memory usage in Spark largely falls(largely falls大幅度下降) under one of two categories(类别；种类；范畴)
: execution and storage. Execution memory refers to that used for computation in shuffles, joins, sorts and aggregations, while storage memory refers to that used for caching and propagating(v.繁殖；增殖；传播；传送) internal data across the cluster. In Spark, execution and storage share a unified region (M). When no execution memory is used, storage can acquire all the available memory and vice versa(当没有execution memory被使用的时候，storage可以获取所有可用内存，反过来也同样). Execution may evict(v. 驱逐；依法收回) storage if necessary, but only until total storage memory usage falls(下降) under a certain threshold (R). In other words, R describes a subregion within M where cached blocks are never evicted. Storage may not evict execution due to complexities in implementation.

This design ensures several desirable(令人满意的) properties. First, applications that do not use caching can use the entire space for execution, obviating(v.排除；消除；避免) unnecessary disk spills. Second, applications that do use caching can reserve(vt.保留；预订；延期) a minimum storage space (R) where their data blocks are immune(adj.免疫的；免除的) to being evicted. Lastly, this approach(n.途径；方法) provides reasonable(adj.合理的；) out-of-the-box(adj.拆盒即可使用的，开箱即用的) performance for a variety of workloads without requiring user expertise(n.专门知识；专门技术；专家的意见) of how memory is divided internally.

Although there are two relevant configurations, the typical user should not need to adjust them as the default values are applicable to most workloads:

* spark.memory.fraction expresses the size of M as a fraction of the (JVM heap space - 300MB) (default 0.6). The rest of the space (40%) is reserved for user data structures, internal metadata in Spark, and safeguarding against OOM errors in the case of sparse and unusually large records.
* spark.memory.storageFraction expresses the size of R as a fraction of M (default 0.5). R is the storage space within M where cached blocks immune to being evicted by execution.
The value of spark.memory.fraction should be set in order to fit this amount of heap space comfortably within the JVM’s old or “tenured” generation. See the discussion of advanced GC tuning below for details.



## Determining Memory Consumption
The best way to size the amount of memory consumption a dataset will require is to create an RDD, put it into cache, and look at the “Storage” page in the web UI. The page will tell you how much memory the RDD is occupying.

To estimate(n.估价；估计) the memory consumption of a particular object, use SizeEstimator’s estimate method This is useful for experimenting with different data layouts to trim memory usage, as well as determining the amount of space a broadcast variable will occupy on each executor heap.


## Tuning Data Structures
The first way to reduce memory consumption is to avoid the Java features that add overhead, such as pointer-based data structures and wrapper objects. There are several ways to do this:

1. Design your data structures to prefer(vt.宁可；较喜欢) arrays of objects, and primitive types, instead of the standard Java or Scala collection classes (e.g. HashMap). The fastutil[http://fastutil.di.unimi.it/] library provides convenient collection classes for primitive types that are compatible with the Java standard library.
2. Avoid nested structures with a lot of small objects and pointers when possible.
3. Consider using numeric IDs or enumeration objects instead of strings for keys.
If you have less than 32 GB of RAM, set the JVM flag -XX:+UseCompressedOops to make pointers be four bytes instead of eight. You can add these options in spark-env.sh.
