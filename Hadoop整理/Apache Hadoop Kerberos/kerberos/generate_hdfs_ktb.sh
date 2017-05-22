#!/bin/bash

SCRIPT=$(basename $0)
function usage(){
    echo -e "\nUSAGE: $SCRIPT <realm> \n"
    exit 1
}

if [ $# -lt 1 ] ; then
   usage
fi

RLEAM=$1
KEYTAB_NAME='hdfs.service.keytab'
for LINE in `cat datanode`  
do   
        echo "rm -rf $KEYTAB_NAME"
        echo "kadmin.local -q \"xst -k $KEYTAB_NAME hdfs/$LINE@${RLEAM}\""
        echo "scp $KEYTAB_NAME root@${LINE}:/etc/security/keytabs/"
done
