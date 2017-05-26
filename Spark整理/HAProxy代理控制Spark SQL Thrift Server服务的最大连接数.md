　Apache Spark 现在是大数据中非常流行的处理引擎，简单的API、内存计算、很好的性能、一站式的解决方案、良好的生态，Spark是大数据中最火的明星AngelaBaby。在Spark内部的多个组件中，SQL组件也是很多公司用的最多的一个内部组件。由于Spark SQL并不适用于大并发的场景，所以在实际的生产过程中发现，由于SparkSQL并不能限制用户数，经常会有过多的用户以及过多的任务，导致Spark SQL 的Thrift Server服务非常不稳定。<br>
　　这个问题在生产过程中非常实际，我们一般建议使用开源软件 HAProxy来解决，下面主要叙述一下具体的解决步骤；顺带一句HAproxy不仅可以解决Spark SQL的连接数，也可以用来用于部署Spark的HA。

1. 安装

　　至HAProxy的官网网站http://www.haproxy.org/下载最新版本的安装包aproxy-1.7.5.tar.gz。
```
　　[root@zdh223 ~]#tar zxvf haproxy-1.7.5.tar.gz
　　[root@zdh223 ~]#cd haproxy-1.7.5
　　[root@zdh223 ~]#make TARGET=zdh221
　　[root@zdh223 ~]#make install
```
　　安装结束。在任意目录下执行 haproxy –vv 如果能正确显示haproxy的版本号，即表示安装正确。

2. 配置

　　在haproxy-1.7.5目录下创建文件sparksql.cfg，文件名可以任意。内容如下：
```
　　global
　　daemon
　　nbproc 1
　　pidfile /root/haproxy-1.7.5/haproxy.pid
　　ulimit-n 65535
　　defaults
　　mode tcp #mode { tcp|http|health }，因为Spark SQL底层使用tcp
　　retries 2
　　option redispatch
　　option abortonclose
　　maxconn 1024
　　timeout connect 1d
　　timeout client 1d
　　timeout server 1d
　　timeout check 2000
　　log 127.0.0.1 local0 err #[err warning info debug]
　　listen admin_stats
　　bind 0.0.0.0:1090#管理界面访问IP和端口
　　mode http
　　maxconn 10 #管理界面最大连接数
　　stats refresh 30s #30秒自动刷新
　　stats uri / #访问url
　　stats realm SparkSql Haproxy #验证窗口提示
　　stats auth admin:123456 #401验证用户名密码
　　listen SparkSql # SparkSql后端定义
　　bind 0.0.0.0:18001 #ha作为proxy所绑定的IP和端口
　　mode tcp #以4层方式代理，重要
　　balance leastconn #调度算法 'leastconn' 最少连接数分配，或者 'roundrobin'，轮询分配
　　maxconn 1024#最大连接数
　　server spark1 10.43.156.221:18000 check inter 180000 rise 1 fall 2
　　server spark2 10.43.156.222:18000 check inter 180000 rise 1 fall 2
　　server spark3 10.43.156.223:18000 check inter 180000 rise 1 fall 2
　　#释义：server 主机代名，IP:端口 每180000毫秒检查一次。也就是三分钟。
```
　　蓝色部分配置需要重点关注，视实际情况配置。

3. 启停

 *  启动
 ```
　　依次启动sparksql后，启动haproxy。
　　haproxy-f sparksql.cfg
 ```
 * 停止
 ```
　　使用ps -ef|grep haproxy检查出进程后kill。
 ```
4. 验证
   
* 功能验证

　　在多台客户端的spark目录下执行：

　　`bin/beeline-u jdbc:hive2://zdh221:18001 -n mr` <br>

　　均可以正常连接，并进行操作。<br>
查看haproxy的web页面，http://10.43.156.221:1090/口令：admin/123456 (上文配置)，可以看到各服务器均有负载。<br>
查看每个sparksql的后台日志，可以看到均有业务日志。

 * 最大连接数验证

更改上文配置文件中的listen SparkSql下的maxconn 1024为2，并重启haproxy。
当在2台客户端的spark目录下使用beeline，均可以连接并操作，当使用第3台客户端的beeline连接时候，会显示连接等待，无法连接。
查看http://10.43.156.221:1090/页面，可以看到最大连接数设置的为2。