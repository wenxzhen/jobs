#!/bin/bash

SCRIPT=$(basename $0)
function usage(){
    echo -e "\nUSAGE: $SCRIPT <host> <port> <user> <password> <db> <table> <outdir>\n"
    exit 1
}

if [ $# -lt 7 ] ; then
   usage
fi

mysqldump -h$1 -u$3 -p$4 $5 $6 \
  --skip-lock-tables\
  --skip-add-locks\
  --skip-comments\
  --skip-add-drop-table\
  --no-create-info\
  --skip-extended-insert\
  --where="1 > 0" | grep -o -E "\(.*+\)" | sed "s/^(//g" | sed "s/)$//g" > $7