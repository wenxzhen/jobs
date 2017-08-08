#!/bin/bash

host=192.168.6.145
user=root
passwd=root
db=test
table=kylin_country
output=kylin_country.txt 
step=100

rm -rf $output

count=`mysql -h$host -u$user  -p$passwd -e "SELECT count(1) FROM  $table ;"  $db | awk 'NR!=1{print $0}'`

for (( i=0;i<$count;i=i+$step))
do
     echo "SELECT * FROM $table limit $i , $step ;"
     mysql -h$host -u$user  -p$passwd -e "SELECT * FROM $table limit $i , $step ;" $db | awk 'NR!=1{print $0}' >> $output
done 