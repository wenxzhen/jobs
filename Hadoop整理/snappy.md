# 编译环境
```
$ cat /etc/redhat-release 
CentOS Linux release 7.2.1511 (Core)

$ mvn -version
Apache Maven 3.3.9 (bb52d8502b132ec0a5a3f4c09453c07478323dc5; 2015-11-11T00:41:47+08:00)
Maven home: /opt/apache-maven-3.3.9
Java version: 1.8.0_101, vendor: Oracle Corporation
Java home: /opt/jdk1.8.0_101/jre
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "3.10.0-327.el7.x86_64", arch: "amd64", family: "unix"

$ java -version
java version "1.8.0_101"
Java(TM) SE Runtime Environment (build 1.8.0_101-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.101-b13, mixed mode)
```
# 编译hadoop
```
$ wget http://www.apache.org/dyn/closer.cgi/hadoop/common/hadoop-2.7.3/hadoop-2.7.3-src.tar.gz
$ yum install protobuf protobuf-devel cmake zlib snappy snappy-devel openssl openssl-devel -y
$ tar -xzvf hadoop-2.7.3-src.tar.gz
$ cd hadoop-2.7.3-src
$ mvn package -Pdist,native -DskipTests -Dtar  -Drequire.snappy
$ ll hadoop-dist/target/
total 580512
drwxr-xr-x 9 root root       139 Apr 19 15:05 hadoop-2.7.3
-rw-r--r-- 1 root root 197682605 Apr 19 15:05 hadoop-2.7.3.tar.gz
-rw-r--r-- 1 root root     26291 Apr 19 15:05 hadoop-dist-2.7.3.jar
-rw-r--r-- 1 root root 396672110 Apr 19 15:06 hadoop-dist-2.7.3-javadoc.jar
-rw-r--r-- 1 root root     23820 Apr 19 15:05 hadoop-dist-2.7.3-sources.jar
-rw-r--r-- 1 root root     23820 Apr 19 15:05 hadoop-dist-2.7.3-test-sources.jar

```

# 在运行hadoop的机器上安装snappy 本地库
```
sudo yum install snappy -y
```

# hadoop配置修改
用编译出的hadoop-dist/target/hadoop-2.7.3.tar.gz 进行部署，hadoop的具体部署过程不知复述，以下主要是snappy相关配置。
## core-site.xml
```
$ vi $HADOOP_HOME/etc/hadoop/core-site.xml

<property>
  <name>io.compression.codecs</name>
  <value>org.apache.hadoop.io.compress.GzipCodec,
    org.apache.hadoop.io.compress.DefaultCodec,
    org.apache.hadoop.io.compress.BZip2Codec,
    org.apache.hadoop.io.compress.SnappyCodec
  </value>
</property>

```

## mapred-site.xml
```
$ vi $HADOOP_HOME/etc/hadoop/mapred-site.xml

  <property>
      <name>mapreduce.map.output.compress</name> 
      <value>true</value>
  </property>
              
  <property>
      <name>mapreduce.map.output.compress.codec</name> 
      <value>org.apache.hadoop.io.compress.SnappyCodec</value>
   </property>

```

# HBase 启用snappy
```
$ vi $HBASE_HOME/conf/hbase-env.sh

export HBASE_LIBRARY_PATH=$HBASE_LIBRARY_PATH:$HADOOP_HOME/lib/native/
```

# 验证
```
$ ll $HADOOP_HOME/lib/native
total 4496
-rw-r--r--. 1 hadoop hadoop 1210172 Jan 21 15:38 libhadoop.a
-rw-r--r--. 1 hadoop hadoop 1487276 Jan 21 15:38 libhadooppipes.a
lrwxrwxrwx. 1 hadoop hadoop      18 Jan 21 15:38 libhadoop.so -> libhadoop.so.1.0.0
-rwxr-xr-x. 1 hadoop hadoop  715860 Jan 21 15:38 libhadoop.so.1.0.0
-rw-r--r--. 1 hadoop hadoop  582056 Jan 21 15:38 libhadooputils.a
-rw-r--r--. 1 hadoop hadoop  364772 Jan 21 15:38 libhdfs.a
lrwxrwxrwx. 1 hadoop hadoop      16 Jan 21 15:38 libhdfs.so -> libhdfs.so.0.0.0
-rwxr-xr-x. 1 hadoop hadoop  228945 Jan 21 15:38 libhdfs.so.0.0.0

$ hadoop checknative
17/04/19 14:13:35 WARN bzip2.Bzip2Factory: Failed to load/initialize native-bzip2 library system-native, will use pure-Java version
17/04/19 14:13:35 INFO zlib.ZlibFactory: Successfully loaded & initialized native-zlib library
Native library checking:
hadoop:  true /data/bigdata/hadoop-2.7.3/lib/native/libhadoop.so.1.0.0
zlib:    true /lib64/libz.so.1
snappy:  true /lib64/libsnappy.so.1
lz4:     true revision:99
bzip2:   false 
openssl: true /lib64/libcrypto.so

$ hbase shell
HBase Shell; enter 'help<RETURN>' for list of supported commands.
Type "exit<RETURN>" to leave the HBase Shell
Version 1.1.3, r72bc50f5fafeb105b2139e42bbee3d61ca724989, Sat Jan 16 18:29:00 PST 2016
hbase(main):001:0> create 'testsnap', {NAME=>'cf', COMPRESSION=>'SNAPPY'} 
0 row(s) in 1.6680 seconds

=> Hbase::Table - testsnap
```