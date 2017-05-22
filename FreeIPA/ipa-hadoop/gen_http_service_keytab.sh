#!/usr/bin/bash


SCRIPT=$(basename $0)
function usage(){
    echo -e "\nUSAGE: $SCRIPT <realm> \n"
    exit 1
}

if [ $# -lt 1 ] ; then
   usage
fi

ipa_server=$(cat /etc/ipa/default.conf | awk '/^server =/ {print $3}')

RLEAM=$1

KEYTAB_NAME='spnego.service.keytab'

for LINE in `awk '/^[^#]/ { print }' datanode | cat`  
do   
        echo "ipa-getkeytab -s ${ipa_server} -p HTTP/${LINE}@${RLEAM} -k ${KEYTAB_NAME}"
        echo "chown hdfs:hadoop ${KEYTAB_NAME};chmod 400 ${KEYTAB_NAME}"
        echo "scp -p $KEYTAB_NAME root@${LINE}:/etc/security/keytabs/"
        echo "rm -rf $KEYTAB_NAME"
done

