# linux下一个网卡如何配置多个IP

ifconfig的用法可以使用man ifconfig查看，最常用的给网卡配置ip的命令为 
```
＃ifconfig eth0 192.168.0.1 netmask 255.255.255.0 up \
```
说明： 
* eth0是第一个网卡，其他依次为eth1，eth* 
* 192.168.0.1是给网卡配置的第一个网卡配置的ip地址 
* netmask 255.255.255.0 配置的是子网掩码 
* up是表示立即激活 

如果给单个网卡eth0配置多个ip地址如何操作呢，如果使用ifconfig命令那么上边需要改动的地方只有eth0这个而已，查了一些资料，明白了将eth0改为eth0:x(x是0－255例如eth0:0或者eth0:1等等),eth0:x称为虚拟网络接口，是建立在网络借口(eth0)上边。 
所以给单网卡配置多ip的方法就是使用命令：
``` 
#ifconfig eth0:0 192.168.0.1 netmask 255.255.255.0 up 
#ifconfig eth0:1 192.168.0.2 netmask 255.255.255.0 up 
#ping 192.168.0.1 
#ping 192.168.0.2 
```
ping测试通过，就完成了单网卡配置多ip的功能。reboot以后发现ip地址变了回去。 

所以必须设置启动时自动激活ip设置 
* 第一种： 
将上边的命令ifconfig加入到rc.local中去 
* 第二种： 
就是仿照/etc/sysconfig/network-scripts/ifcfg-eth0增加一文件根据网络虚拟接口的名字进行命名 

例如ifcfg-eth0:0或者ifcfg-eth0:1等等 
#下边看下ifcfg-eth0:0文件里面的配置信息 
DEVICE=eth0:0 #网络虚拟接口eth0:0 <br>
ONBOOT=yes #启动的时候激活 <br>
BOOTPROTO=static #使用静态ip地址 <br>
IPADDR=192.168.0.1 #分配ip地址 <br>
NETMASK=255.255.255.0 #子网掩码 <br>
其他配置文件类似。重启ping测试，配置成功。 <br>
今天看了别人的没看明白自己试了试才知道具体如何操作。<br> 
如何关闭一个ip呢则使用 <br>
`#ifconfig eth*[:x] down(*代表的是网卡编号，x代表虚拟接口号0－255) `<br>
查看ip配置信息： <br>
`#ifconfig `


# 实例
```
[root@maven network-scripts]# pwd
/etc/sysconfig/network-scripts

[root@maven network-scripts]# cp ifcfg-eno16777736 ifcfg-eno16777736:1

[root@maven network-scripts]# cat ifcfg-eno16777736:1
DEVICE=eno16777736:1
BOOTPROTO=static
ONBOOT=yes
NM_CONTROLLED=no
IPADDR=192.168.76.150
NETMASK=255.255.255.0

[root@maven network-scripts]# ifup eno16777736:1
[root@maven network-scripts]# ifconfig eno16777736
eno16777736: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.76.132  netmask 255.255.255.0  broadcast 192.168.76.255
        inet6 fe80::20c:29ff:fe6f:9f88  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:6f:9f:88  txqueuelen 1000  (Ethernet)
        RX packets 1015  bytes 81095 (79.1 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 482  bytes 88057 (85.9 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


[root@maven network-scripts]# ifconfig eno16777736:1
eno16777736:1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.76.150  netmask 255.255.255.0  broadcast 192.168.76.255
        ether 00:0c:29:6f:9f:88  txqueuelen 1000  (Ethernet)

[root@maven network-scripts]# ping 192.168.76.150
PING 192.168.76.150 (192.168.76.150) 56(84) bytes of data.
64 bytes from 192.168.76.150: icmp_seq=1 ttl=64 time=0.137 ms
64 bytes from 192.168.76.150: icmp_seq=2 ttl=64 time=0.053 ms
64 bytes from 192.168.76.150: icmp_seq=3 ttl=64 time=0.052 ms
64 bytes from 192.168.76.150: icmp_seq=4 ttl=64 time=0.051 ms
--- 192.168.76.150 ping statistics ---
7 packets transmitted, 7 received, 0% packet loss, time 6000ms
rtt min/avg/max/mdev = 0.049/0.063/0.137/0.031 ms

[root@maven network-scripts]# ifdown eno16777736:1

```