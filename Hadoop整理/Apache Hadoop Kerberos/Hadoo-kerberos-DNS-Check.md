如何解决Kerberos问题: "Server has invalid Kerberos principal: hdfs/host2@****.COM"

2015-06-12 00:44 本站整理 浏览(143)
在试图连接 带有Kerberos安全认证的CDH Hadoop集群时，碰到标题所述问题：（已经按要求替换了jre中的security目录下两个jar包，也已经导入证书，具体过程略）

问题样例 ： 
13/10/25 10:52:24 ERROR security.UserGroupInformation: PriviledgedActionException as:user/host1@****.COM (auth:KERBEROS) cause:java.io.IOException: java.lang.IllegalArgumentException: Server has invalid Kerberos principal: user/host2@****.COM
13/10/25 10:52:24 WARN ipc.Client: Exception encountered while connecting to the server : java.lang.IllegalArgumentException: Server has invalid Kerberos principal: user/host3@****.COM
13/10/25 10:52:24 ERROR security.UserGroupInformation: PriviledgedActionException as:user/host1@****.COM (auth:KERBEROS) cause:java.io.IOException: java.lang.IllegalArgumentException:Server has invalid Kerberos principal:
user/host2@****.COM
解决办法：
```
java -classpath HadoopDNSVerifier-1.0.jar hadoop.troubleshooting.HadoopDNSVerifier.CheckRemote  host1
```
如果结果类似如下内容：
```
IP:10.181.22.149 hostname:host1 canonicalName:10.181.22.149
```
可以在该应用服务器上通过 /etc/hosts绑定 host1及其对应ip, 再次运行上面的HadoopDNSVerifier-1.0.jar, 结果应该如下：
```
IP:10.181.22.149 hostname:host1 canonicalName:host1
```
这时重新导入证书( kinit ... -t xxx.keytab your_principal ), 然后运行 hadoop fs -ls /，即发现连接 CDH Hadoop成功
以下是下载 HadoopDNSVerifier-1.0.jar的地址： 
https://support.pivotal.io/hc/en-us/articles/204391148-How-to-Verify-DNS-settings-in-your-Hadoop-Cluster