#!/usr/bin/bash

SCRIPT=$(basename $0)
function usage(){
    echo -e "\nUSAGE: $SCRIPT <realm> \n"
    exit 1
}

if [ $# -lt 1 ] ; then
   usage
fi

RLEAM=$1
awk '/^[^#]/ { print "ipa service-add --force HTTP/"$1"@'${RLEAM}'" }' datanode
