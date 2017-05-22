# Hive-Tez Compatibility
https://cwiki.apache.org/confluence/display/Hive/Hive-Tez+Compatibility

# Download Tez
```
wget http://archive.apache.org/dist/tez/0.8.2/apache-tez-0.8.2-src.tar.gz
```

# Required
```
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install protobuf protobuf-compiler
```

# Compile Tez

change the value of the `hadoop.version` property in the top-level pom.xml 
to match the version of the hadoop branch being used.

```
tar -xzvf apache-tez-0.8.2-src.tar.gz
cd apache-tez-0.8.2-src
mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true
```
apache-tez-0.8.2-src/tez-dist/target/tez-0.8.2.tar.gz

# Add tez-site.xml to $HADOOP_HOME/etc/hadoop/tez-site.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
        <property>
                <name>tez.lib.uris</name>
                <value>${fs.defaultFS}/apps/tez-0.8.2.tar.gz</value>
        </property>
</configuration>
```