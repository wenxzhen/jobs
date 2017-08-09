#!/bin/bash

SCRIPT=$(basename $0)
function usage(){
    echo -e "\nUSAGE: $SCRIPT <host> <port> <user> <password> <db> <table> <idcolum>\n"
    exit 1
}

if [ $# -lt 7 ] ; then
   usage
fi

host=$1
port=$2
user=$3
passwd=$4
db=$5
table=$6
idcol=$7
step=100
output=${table}.txt 

rm -rf $output

min=`mysql -h$host -u$user  -p$passwd -P$port -e "SELECT min($idcol) FROM  $table ;"  $db | awk 'NR!=1{print $0}'`
max=`mysql -h$host -u$user  -p$passwd -P$port -e "SELECT max($idcol) FROM  $table ;"  $db | awk 'NR!=1{print $0}'`

for (( i=$min;i<$max;i=i+$step))
do
     echo "SELECT * FROM $table where $idcol >=$i limit $step ;"
     mysql -h$host -u$user  -p$passwd -P$port -e "SELECT * FROM $table where $idcol >=$i limit $step ;" $db | awk 'NR!=1{print $0}' >> $output
done 