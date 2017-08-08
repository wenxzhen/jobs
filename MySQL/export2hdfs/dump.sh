#!/bin/bash

SCRIPT=$(basename $0)
function usage(){
    echo -e "\nUSAGE: $SCRIPT <host> <port> <user> <password> <db> <table>\n"
    exit 1
}

if [ $# -lt 6 ] ; then
   usage
fi

host=$1
port=$2
user=$3
passwd=$4
db=$5
table=$6
step=100
output=${table}.txt 

rm -rf $output

count=`mysql -h$host -u$user  -p$passwd -P$port -e "SELECT count(1) FROM  $table ;"  $db | awk 'NR!=1{print $0}'`

for (( i=0;i<$count;i=i+$step))
do
     echo "SELECT * FROM $table limit $i , $step ;"
     mysql -h$host -u$user  -p$passwd -P$port -e "SELECT * FROM $table limit $i , $step ;" $db | awk 'NR!=1{print $0}' >> $output
done 