#!/bin/bash

SCRIPT=$(basename $0)
function usage(){
    echo -e "\nUSAGE: $SCRIPT <host> <port> <user> <password> <db> <table> <where>\n"
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

where=$7

output=${table}.txt 

rm -rf $output

echo "SELECT * FROM $table where $where ;"
mysql -h$host -u$user  -p$passwd -P$port -e "SELECT * FROM $table where $where ;" $db | awk 'NR!=1{print $0}' >> $output
