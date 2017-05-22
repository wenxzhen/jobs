# 安装Ranger

## 编译
[Build Ranger Admin from source ](https://cwiki.apache.org/confluence/display/RANGER/Ranger+Installation+Guide#RangerInstallationGuide-BuildingRangerfromsource)
```
$ mvn -version
Apache Maven 3.3.9 (bb52d8502b132ec0a5a3f4c09453c07478323dc5; 2015-11-11T00:41:47+08:00)
Maven home: /opt/apache-maven-3.3.9
Java version: 1.8.0_101, vendor: Oracle Corporation
Java home: /opt/jdk1.8.0_101/jre
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "3.10.0-327.el7.x86_64", arch: "amd64", family: "unix"

$ yum install gcc 

$ git clone https://github.com/apache/ranger.git

$ cd ranger

$ mvn clean compile package assembly:assembly install

$ ls target/*.tar.gz
target/ranger-0.7.0-admin.tar.gz         target/ranger-0.7.0-migration-util.tar.gz
target/ranger-0.7.0-atlas-plugin.tar.gz  target/ranger-0.7.0-ranger-tools.tar.gz
target/ranger-0.7.0-hbase-plugin.tar.gz  target/ranger-0.7.0-solr-plugin.tar.gz
target/ranger-0.7.0-hdfs-plugin.tar.gz   target/ranger-0.7.0-src.tar.gz
target/ranger-0.7.0-hive-plugin.tar.gz   target/ranger-0.7.0-storm-plugin.tar.gz
target/ranger-0.7.0-kafka-plugin.tar.gz  target/ranger-0.7.0-tagsync.tar.gz
target/ranger-0.7.0-kms.tar.gz           target/ranger-0.7.0-usersync.tar.gz
target/ranger-0.7.0-knox-plugin.tar.gz   target/ranger-0.7.0-yarn-plugin.tar.gz

```

## 安装 Solr
[Install and Configure Solr for Ranger Audits](https://cwiki.apache.org/confluence/display/RANGER/Install+and+Configure+Solr+for+Ranger+Audits+-+Apache+Ranger+0.5)

```
$ wget http://archive.apache.org/dist/lucene/solr/5.2.1/solr-5.2.1.tgz
$ tar -xzvf solr-5.2.1.tgz
$ cd solr-5.2.1
$ bin/solr start -p 6083
```
## Free IPA Install
```
$ yum install ipa-server -y
$ hostnamectl --static set-hostname ipa.csdn.net
$ ipa-server-install
ipa-server-install

The log file for this installation can be found in /var/log/ipaserver-install.log
==============================================================================
This program will set up the IPA Server.

This includes:
  * Configure a stand-alone CA (dogtag) for certificate management
  * Configure the Network Time Daemon (ntpd)
  * Create and configure an instance of Directory Server
  * Create and configure a Kerberos Key Distribution Center (KDC)
  * Configure Apache (httpd)

To accept the default shown in brackets, press the Enter key.

WARNING: conflicting time&date synchronization service 'chronyd' will be disabled
in favor of ntpd

Do you want to configure integrated DNS (BIND)? [no]: 

Enter the fully qualified domain name of the computer
on which you're setting up server software. Using the form
<hostname>.<domainname>
Example: master.example.com.


Server host name [node01.csdn.net]: 

ipa.ipapython.install.cli.install_tool(Server): ERROR    The host name node01.csdn.net does not match the primary host name node01. Please check /etc/hosts or DNS name resolution

ipa.ipapython.install.cli.install_tool(Server): ERROR    The ipa-server-install command failed. See /var/log/ipaserver-install.log for more information
[root@node01 ~]# vi /etc/hosts
[root@node01 ~]# ipa-server-install

The log file for this installation can be found in /var/log/ipaserver-install.log
==============================================================================
This program will set up the IPA Server.

This includes:
  * Configure a stand-alone CA (dogtag) for certificate management
  * Configure the Network Time Daemon (ntpd)
  * Create and configure an instance of Directory Server
  * Create and configure a Kerberos Key Distribution Center (KDC)
  * Configure Apache (httpd)

To accept the default shown in brackets, press the Enter key.

WARNING: conflicting time&date synchronization service 'chronyd' will be disabled
in favor of ntpd

Do you want to configure integrated DNS (BIND)? [no]: 

Enter the fully qualified domain name of the computer
on which you're setting up server software. Using the form
<hostname>.<domainname>
Example: master.example.com.


Server host name [node01.csdn.net]: 

The domain name has been determined based on the host name.

Please confirm the domain name [csdn.net]: 

The kerberos protocol requires a Realm name to be defined.
This is typically the domain name converted to uppercase.

Please provide a realm name [CSDN.NET]: 
Certain directory server operations require an administrative user.
This user is referred to as the Directory Manager and has full access
to the Directory for system management tasks and will be added to the
instance of directory server created for IPA.
The password must be at least 8 characters long.

Directory Manager password: 
Password (confirm): 

The IPA server requires an administrative user, named 'admin'.
This user is a regular system account used for IPA server administration.

IPA admin password: 
Password (confirm): 


The IPA Master Server will be configured with:
Hostname:       node01.csdn.net
IP address(es): 172.17.0.1, 192.168.76.135, 192.168.122.1
Domain name:    csdn.net
Realm name:     CSDN.NET

Continue to configure the system with these values? [no]: yes

The following operations may take some minutes to complete.
Please wait until the prompt is returned.

Configuring NTP daemon (ntpd)
  [1/4]: stopping ntpd
  [2/4]: writing configuration
  [3/4]: configuring ntpd to start on boot
  [4/4]: starting ntpd
Done configuring NTP daemon (ntpd).
Configuring directory server (dirsrv). Estimated time: 1 minute
  [1/47]: creating directory server user
  [2/47]: creating directory server instance
  [3/47]: updating configuration in dse.ldif
  [4/47]: restarting directory server
  [5/47]: adding default schema
  [6/47]: enabling memberof plugin
  [7/47]: enabling winsync plugin
  [8/47]: configuring replication version plugin
  [9/47]: enabling IPA enrollment plugin
  [10/47]: enabling ldapi
  [11/47]: configuring uniqueness plugin
  [12/47]: configuring uuid plugin
  [13/47]: configuring modrdn plugin
  [14/47]: configuring DNS plugin
  [15/47]: enabling entryUSN plugin
  [16/47]: configuring lockout plugin
  [17/47]: configuring topology plugin
  [18/47]: creating indices
  [19/47]: enabling referential integrity plugin
  [20/47]: configuring certmap.conf
  [21/47]: configure autobind for root
  [22/47]: configure new location for managed entries
  [23/47]: configure dirsrv ccache
  [24/47]: enabling SASL mapping fallback
  [25/47]: restarting directory server
  [26/47]: adding sasl mappings to the directory
  [27/47]: adding default layout
  [28/47]: adding delegation layout
  [29/47]: creating container for managed entries
  [30/47]: configuring user private groups
  [31/47]: configuring netgroups from hostgroups
  [32/47]: creating default Sudo bind user
  [33/47]: creating default Auto Member layout
  [34/47]: adding range check plugin
  [35/47]: creating default HBAC rule allow_all
  [36/47]: adding sasl mappings to the directory
  [37/47]: adding entries for topology management
  [38/47]: initializing group membership
  [39/47]: adding master entry
  [40/47]: initializing domain level
  [41/47]: configuring Posix uid/gid generation
  [42/47]: adding replication acis
  [43/47]: enabling compatibility plugin
  [44/47]: activating sidgen plugin
  [45/47]: activating extdom plugin
  [46/47]: tuning directory server
  [47/47]: configuring directory to start on boot
Done configuring directory server (dirsrv).
Configuring certificate server (pki-tomcatd). Estimated time: 3 minutes 30 seconds
  [1/31]: creating certificate server user
  [2/31]: configuring certificate server instance
  [3/31]: stopping certificate server instance to update CS.cfg
  [4/31]: backing up CS.cfg
  [5/31]: disabling nonces
  [6/31]: set up CRL publishing
  [7/31]: enable PKIX certificate path discovery and validation
  [8/31]: starting certificate server instance
  [9/31]: creating RA agent certificate database
  [10/31]: importing CA chain to RA certificate database
  [11/31]: fixing RA database permissions
  [12/31]: setting up signing cert profile
  [13/31]: setting audit signing renewal to 2 years
  [14/31]: restarting certificate server
  [15/31]: requesting RA certificate from CA
  [16/31]: issuing RA agent certificate
  [17/31]: adding RA agent as a trusted user
  [18/31]: authorizing RA to modify profiles
  [19/31]: authorizing RA to manage lightweight CAs
  [20/31]: Ensure lightweight CAs container exists
  [21/31]: configure certmonger for renewals
  [22/31]: configure certificate renewals
  [23/31]: configure RA certificate renewal
  [24/31]: configure Server-Cert certificate renewal
  [25/31]: Configure HTTP to proxy connections
  [26/31]: restarting certificate server
  [27/31]: migrating certificate profiles to LDAP
  [28/31]: importing IPA certificate profiles
  [29/31]: adding default CA ACL
  [30/31]: adding 'ipa' CA entry
  [31/31]: updating IPA configuration
Done configuring certificate server (pki-tomcatd).
Configuring directory server (dirsrv). Estimated time: 10 seconds
  [1/3]: configuring ssl for ds instance
  [2/3]: restarting directory server
  [3/3]: adding CA certificate entry
Done configuring directory server (dirsrv).
Configuring Kerberos KDC (krb5kdc). Estimated time: 30 seconds
  [1/9]: adding kerberos container to the directory
  [2/9]: configuring KDC
  [3/9]: initialize kerberos container
  [4/9]: adding default ACIs
  [5/9]: creating a keytab for the directory
  [6/9]: creating a keytab for the machine
  [7/9]: adding the password extension to the directory
  [8/9]: starting the KDC
  [9/9]: configuring KDC to start on boot
Done configuring Kerberos KDC (krb5kdc).
Configuring kadmin
  [1/2]: starting kadmin 
  [2/2]: configuring kadmin to start on boot
Done configuring kadmin.
Configuring ipa_memcached
  [1/2]: starting ipa_memcached 
  [2/2]: configuring ipa_memcached to start on boot
Done configuring ipa_memcached.
Configuring ipa-otpd
  [1/2]: starting ipa-otpd 
  [2/2]: configuring ipa-otpd to start on boot
Done configuring ipa-otpd.
Configuring ipa-custodia
  [1/5]: Generating ipa-custodia config file
  [2/5]: Making sure custodia container exists
  [3/5]: Generating ipa-custodia keys
  [4/5]: starting ipa-custodia 
  [5/5]: configuring ipa-custodia to start on boot
Done configuring ipa-custodia.
Configuring the web interface (httpd). Estimated time: 1 minute
  [1/21]: setting mod_nss port to 443
  [2/21]: setting mod_nss cipher suite
  [3/21]: setting mod_nss protocol list to TLSv1.0 - TLSv1.2
  [4/21]: setting mod_nss password file
  [5/21]: enabling mod_nss renegotiate
  [6/21]: adding URL rewriting rules
  [7/21]: configuring httpd
  [8/21]: configure certmonger for renewals
  [9/21]: setting up httpd keytab
  [10/21]: setting up ssl
  [11/21]: importing CA certificates from LDAP
  [12/21]: setting up browser autoconfig
  [13/21]: publish CA cert
  [14/21]: clean up any existing httpd ccache
  [15/21]: configuring SELinux for httpd
  [16/21]: create KDC proxy user
  [17/21]: create KDC proxy config
  [18/21]: enable KDC proxy
  [19/21]: restarting httpd
  [20/21]: configuring httpd to start on boot
  [21/21]: enabling oddjobd
Done configuring the web interface (httpd).
Applying LDAP updates
Upgrading IPA:
  [1/9]: stopping directory server
  [2/9]: saving configuration
  [3/9]: disabling listeners
  [4/9]: enabling DS global lock
  [5/9]: starting directory server
  [6/9]: upgrading server
  [7/9]: stopping directory server
  [8/9]: restoring configuration
  [9/9]: starting directory server
Done.
Restarting the directory server
Restarting the KDC
ipa         : ERROR    unable to resolve host name node01.csdn.net. to IP address, ipa-ca DNS record will be incomplete
Please add records in this file to your DNS system: /tmp/ipa.system.records.tDj9TV.db
Restarting the web server
Configuring client side components
Using existing certificate '/etc/ipa/ca.crt'.
Client hostname: node01.csdn.net
Realm: CSDN.NET
DNS Domain: csdn.net
IPA Server: node01.csdn.net
BaseDN: dc=csdn,dc=net

Skipping synchronizing time with NTP server.
New SSSD config will be created
Configured sudoers in /etc/nsswitch.conf
Configured /etc/sssd/sssd.conf
trying https://node01.csdn.net/ipa/json
Forwarding 'schema' to json server 'https://node01.csdn.net/ipa/json'
trying https://node01.csdn.net/ipa/session/json
Forwarding 'ping' to json server 'https://node01.csdn.net/ipa/session/json'
Forwarding 'ca_is_enabled' to json server 'https://node01.csdn.net/ipa/session/json'
Systemwide CA database updated.
Adding SSH public key from /etc/ssh/ssh_host_rsa_key.pub
Adding SSH public key from /etc/ssh/ssh_host_ecdsa_key.pub
Adding SSH public key from /etc/ssh/ssh_host_ed25519_key.pub
Forwarding 'host_mod' to json server 'https://node01.csdn.net/ipa/session/json'
Could not update DNS SSHFP records.
SSSD enabled
Configured /etc/openldap/ldap.conf
Configured /etc/ssh/ssh_config
Configured /etc/ssh/sshd_config
Configuring csdn.net as NIS domain.
Client configuration complete.

==============================================================================
Setup complete

Next steps:
	1. You must make sure these network ports are open:
		TCP Ports:
		  * 80, 443: HTTP/HTTPS
		  * 389, 636: LDAP/LDAPS
		  * 88, 464: kerberos
		UDP Ports:
		  * 88, 464: kerberos
		  * 123: ntp

	2. You can now obtain a kerberos ticket using the command: 'kinit admin'
	   This ticket will allow you to use the IPA tools (e.g., ipa user-add)
	   and the web user interface.

Be sure to back up the CA certificates stored in /root/cacert.p12
These files are required to create replicas. The password for these
files is the Directory Manager password

```
## 安装 MariaDB
```
$ yum install mariadb*
$ systemctl start mariadb.service
$ mysql -u root -p
Enter password:  ##首次登录密码为空
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 2
Server version: 5.5.52-MariaDB MariaDB Server

Copyright (c) 2000, 2016, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> use mysql;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
MariaDB [mysql]>  update user set password=password('csdn.net') where user='root';
Query OK, 4 rows affected (0.00 sec)
Rows matched: 4  Changed: 4  Warnings: 0

MariaDB [mysql]> CREATE USER 'ranger'@'%' IDENTIFIED BY 'ranger';
Query OK, 0 rows affected (0.00 sec)

MariaDB [mysql]> GRANT ALL PRIVILEGES ON *.* TO 'ranger'@'%';
Query OK, 0 rows affected (0.01 sec)

MariaDB [mysql]> GRANT ALL PRIVILEGES ON *.* TO 'ranger'@'%' WITH GRANT OPTION;
Query OK, 0 rows affected (0.00 sec)

```
## 安装 Ranger
```
$ tar -xzvf ranger-0.7.0-admin.tar.gz -C /usr/local
$ cd /usr/local/ranger-0.7.0-admin
$ vi install.properties

DB_FLAVOR=MYSQL
SQL_CONNECTOR_JAR=/usr/share/java/mysql-connector-java.jar
db_root_user=root
db_root_password=root
db_host=192.168.6.145:3306

#
# DB UserId used for the Ranger schema
#
db_name=ranger
db_user=root
db_password=root

#Source for Audit Store
#audit_store=solr|db
# 
audit_store=db
audit_db_name=ranger
audit_db_user=root
audit_db_password=root

#
# ------- PolicyManager CONFIG ----------------
#
policymgr_external_url=http://node02:6080
policymgr_http_enabled=true

####LDAP settings - Required only if have selected LDAP authentication ####
#
# Sample Settings
#
xa_ldap_url=ldap://192.168.76.135:389
xa_ldap_userDNpattern=uid={0},ou=users,dc=csdn,dc=net
xa_ldap_groupSearchBase=ou=groups,dc=csdn,dc=net
xa_ldap_groupSearchFilter=(member=uid={0},ou=users,dc=csdn,dc=net)
xa_ldap_groupRoleAttribute=cn
xa_ldap_base_dn=dc=csdn,dc=net
xa_ldap_bind_dn=cn=admin,ou=users,dc=csdn,dc=net
xa_ldap_bind_password=csdn.net
xa_ldap_referral=follow
xa_ldap_userSearchFilter=(uid={0})

$ ./setup.sh
.......
Installation of Ranger PolicyManager Web Application is completed.

$ ranger-admin start
Starting Apache Ranger Admin Service
Apache Ranger Admin Service with pid 20861 has started.
```

## Installing the Ranger UserSync Process
```
$ tar -xzvf ranger-0.7.0-usersync.tar.gz -C /usr/local
$ cd /usr/local/ranger-0.7.0-usersync
```

## Enabling Ranger HDFS Plugins
```
$ tar -xzvf ranger-0.7.0-hdfs-plugin.tar.gz -C /usr/local
$ cd /usr/local/ranger-0.7.0-hdfs-plugin
$ vi install.properties
#
# Location of Policy Manager URL  
#
# Example:
# POLICY_MGR_URL=http://policymanager.xasecure.net:6080
#
POLICY_MGR_URL=http://node02:6080

SQL_CONNECTOR_JAR=/usr/share/java/mysql-connector-java.jar

#
# This is the repository name created within policy manager
#
# Example:
# REPOSITORY_NAME=hadoopdev
#
REPOSITORY_NAME=csdn-hadoop

XAAUDIT.DB.IS_ENABLED=true
XAAUDIT.DB.FLAVOUR=MYSQL
XAAUDIT.DB.HOSTNAME=192.168.76.135
XAAUDIT.DB.DATABASE_NAME=ranger
XAAUDIT.DB.USER_NAME=ranger
XAAUDIT.DB.PASSWORD=ranger

$ sudo ln -s /usr/local/hadoop-2.7.3/ /usr/local/hadoop
$ sudo ln -s /usr/local/hadoop-2.7.3/etc/hadoop /usr/local/hadoop/conf
$ ./enable-hdfs-plugin.sh 
Custom user and group are not available, using default user and group.
+ Tue Apr 11 15:04:40 CST 2017 : hadoop: lib folder=/usr/local/hadoop/lib conf folder=/usr/local/hadoop/conf
+ Tue Apr 11 15:04:40 CST 2017 : Saving current config file: /usr/local/hadoop/conf/hdfs-site.xml to /usr/local/hadoop/conf/.hdfs-site.xml.20170411-150440 ...
+ Tue Apr 11 15:04:41 CST 2017 : Saving current config file: /usr/local/hadoop/conf/ranger-hdfs-audit.xml to /usr/local/hadoop/conf/.ranger-hdfs-audit.xml.20170411-150440 ...
+ Tue Apr 11 15:04:41 CST 2017 : Saving current config file: /usr/local/hadoop/conf/ranger-hdfs-security.xml to /usr/local/hadoop/conf/.ranger-hdfs-security.xml.20170411-150440 ...
+ Tue Apr 11 15:04:41 CST 2017 : Saving current config file: /usr/local/hadoop/conf/ranger-policymgr-ssl.xml to /usr/local/hadoop/conf/.ranger-policymgr-ssl.xml.20170411-150440 ...
+ Tue Apr 11 15:04:42 CST 2017 : Saving current JCE file: /etc/ranger/csdn-hadoop/cred.jceks to /etc/ranger/csdn-hadoop/.cred.jceks.20170411150442 ...
+ Tue Apr 11 15:04:43 CST 2017 : Saving current JCE file: /etc/ranger/csdn-hadoop/cred.jceks to /etc/ranger/csdn-hadoop/.cred.jceks.20170411150443 ...
Ranger Plugin for hadoop has been enabled. Please restart hadoop to ensure that changes are effective.

$ cp /usr/local/hadoop/lib/* /usr/local/hadoop/share/hadoop/hdfs/lib/
$ stop-dfs.sh
$ start-dfs.sh
```