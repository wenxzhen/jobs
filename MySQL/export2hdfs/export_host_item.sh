mysql -h100.11.4.7 -uzabbix  -pZabbix@123! -e "SELECT * FROM  hosts;"  zabbix | awk 'NR!=1{print $0}' >  hosts.txt
hdfs dfs -mkdir /ywpt/hosts/
hdfs dfs -put hosts.txt /ywpt/hosts
rm -rf hosts.txt
 
mysql -h100.11.4.7 -uzabbix  -pZabbix@123! -e "SELECT * FROM items;"  zabbix | awk 'NR!=1{print $0}' >  items.txt 

hdfs dfs -mkdir /ywpt/items/
hdfs dfs -put items.txt /ywpt/items
rm -rf items.txt

