#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")";pwd) 
while [ $# -gt 0 ] ; do  
  nodeArg=$1  
  exec<${BASE_DIR}/topology.data  
  result=""  
  while read line ; do  
    ar=( $line )  
    if [ "${ar[0]}" = "$nodeArg"  -o  "${ar[1]}" = "$nodeArg" ]; then  
      result="${ar[2]}"  
    fi  
  done 
  if [ -z "$result" ]; then  
    echo "/default-rack"  
  else  
    echo "$result"  
  fi  
  shift
done  
