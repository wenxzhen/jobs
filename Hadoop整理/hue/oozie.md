# Building Oozie
```
$ java -version
java version "1.7.0_79"
Java(TM) SE Runtime Environment (build 1.7.0_79-b15)
Java HotSpot(TM) 64-Bit Server VM (build 24.79-b02, mixed mode)
$ mvn -version
Apache Maven 3.3.9 (bb52d8502b132ec0a5a3f4c09453c07478323dc5; 2015-11-11T00:41:47+08:00)
Maven home: /home/hadoop/apache-maven-3.3.9
Java version: 1.7.0_79, vendor: Oracle Corporation
Java home: /opt/jdk1.7.0_79/jre
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "2.6.32-431.el6.x86_64", arch: "amd64", family: "unix"

$ git clone https://github.com/apache/oozie.git
$ git tag
$ git checkout release-4.3.0

$ bin/mkdistro.sh  -DskipTests -Dhadoop.version=2.7.3  -Pspark-2 -Dspark.version=2.1.0
OR
$ mvn clean package assembly:single -Dhadoop.version=2.7.3  -DskipTests -Pspark-2 -Dspark.version=2.1.0

$ ll distro/target/
total 393584
drwxrwxr-x 2 hadoop hadoop      4096 Apr 12 15:09 antrun
drwxrwxr-x 2 hadoop hadoop      4096 Apr 12 15:15 archive-tmp
drwxrwxr-x 3 hadoop hadoop      4096 Apr 12 15:09 classes
drwxrwxr-x 2 hadoop hadoop      4096 Apr 12 15:09 maven-archiver
drwxrwxr-x 3 hadoop hadoop      4096 Apr 12 15:09 maven-shared-archive-resources
drwxrwxr-x 3 hadoop hadoop      4096 Apr 12 15:15 oozie-4.3.0-distro
-rw-rw-r-- 1 hadoop hadoop 402979850 Apr 12 15:16 oozie-4.3.0-distro.tar.gz
-rw-rw-r-- 1 hadoop hadoop     14453 Apr 12 15:09 oozie-distro-4.3.0.jar
drwxrwxr-x 3 hadoop hadoop      4096 Apr 12 15:09 test-classes
drwxrwxr-x 3 hadoop hadoop      4096 Apr 12 15:15 tomcat
```

# Server Installation

```

$ wget http://archive.cloudera.com/gplextras/misc/ext-2.2.zip

$ tar -xzvf oozie-4.3.0-distro.tar.gz
$ cd oozie-4.3.0
$ mkdir libext
$ mv ext-2.2.zip libext
$ mv mysql-connector-java-5.1.34.jar libext
$ ll libext/
total 7584
-rw-rw-r--. 1 hadoop hadoop 6800612 Jun 12  2013 ext-2.2.zip
-rw-rw-r--. 1 hadoop hadoop  960372 Apr 12 17:38 mysql-connector-java-5.1.34.jar

$ cp ${HADOOP_HOME}/share/hadoop/*/*.jar libext/ 
$ cp ${HADOOP_HOME}/share/hadoop/*/lib/*.jar libext/ 
$ rm libext/jsp-api-2.1.jar
$ bin/oozie-setup.sh prepare-war 
  setting CATALINA_OPTS="$CATALINA_OPTS -Xmx1024m"

INFO: Adding extension: 
.....................
/home/hadoop/oozie-4.3.0/libext/mysql-connector-java-5.1.34.jar
New Oozie WAR file with added 'ExtJS library, JARs' at /home/hadoop/oozie-4.3.0/oozie-server/webapps/oozie.war
INFO: Oozie is ready to be started

$ vi conf/oozie-site.xml
    <property>
        <name>oozie.service.ProxyUserService.proxyuser.hadoop.hosts</name>
        <value>*</value>
    </property>

    <property>
        <name>oozie.service.ProxyUserService.proxyuser.hadoop.groups</name>
        <value>*</value>
    </property>
    <property>
        <name>oozie.service.HadoopAccessorService.hadoop.configurations</name>
        <value>*=/data/bigdata/hadoop/etc/hadoop</value>
    </property>
    
    <property>
        <name>oozie.service.JPAService.jdbc.driver</name>
        <value>com.mysql.jdbc.Driver</value>
    </property>
    <property>
        <name>oozie.service.JPAService.jdbc.url</name>
        <value>jdbc:mysql://master02:3306/oozie</value>
    </property>
    <property>
        <name>oozie.service.JPAService.jdbc.username</name>
        <value>root</value>
    </property>
    <property>
        <name>oozie.service.JPAService.jdbc.password</name>
        <value>MySQL57@csdn.net</value>
    </property>

$ bin/oozie-setup.sh sharelib create -fs hdfs://csdncluster
the destination path for sharelib is: /user/hadoop/share/lib/lib_20170413095410
$ bin/oozie-setup.sh db create -run 
  setting CATALINA_OPTS="$CATALINA_OPTS -Xmx1024m"

Validate DB Connection
DONE
DB schema does not exist
Check OOZIE_SYS table does not exist
DONE
Create SQL schema
DONE
Create OOZIE_SYS table
DONE

Oozie DB has been created for Oozie version '4.3.0'


The SQL commands have been written to: /tmp/ooziedb-1279320728352687832.sql

$ bin/oozie-start.sh
$ bin/oozie admin -oozie http://localhost:11000/oozie -status
System mode: NORMAL
```