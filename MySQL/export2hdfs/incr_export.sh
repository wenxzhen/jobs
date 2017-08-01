date_1=`date -d '-1 day' +%Y-%m-%d`
timestp_1=`date -d "$date_1" +%s`

date=`date +%Y-%m-%d`
timestp=`date -d "$date" +%s`


table=$1

echo "export from $timestp_1 to $timestp"
mysql -h100.11.4.7 -uzabbix  -pZabbix@123! -e "SELECT * FROM $table where clock >= $timestp_1 and  clock < $timestp;"  zabbix | awk 'NR!=1{print $0}' > ${table}_$date_1.txt 


hdfs dfs -mkdir -p /ywpt/$table/$date_1
hdfs dfs -put ${table}_$date_1.txt /ywpt/$table/$date_1/

rm -rf ${table}_$date_1.txt
