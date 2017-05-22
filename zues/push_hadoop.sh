#!/bin/bash

if [ $1 != "" ];then
    dateYes=$1
else
   dateYes=`date -d "-1 days" +%Y%m%d`
fi

Date=`date  +%Y%m%d`
dateHour=`date  +%H`
ip=$(/sbin/ifconfig eth0|grep inet |awk '{print $2}'|cut -d: -f2)
logPath="/opt/openresty/nginx/logs"
logName="push.api.csdn.net.log"
logFile="$logName-$dateYes-$ip"
logFile04="$logName-${Date}04-$ip"
logFile16="$logName-${Date}16-$ip"

file() {
	cp $logPath/$1 $logPath/$2
}
upload() {
        logFile=`ls $logPath|grep $1`
	wget  "http://CSDN-HDP-ZSS-02:8585/zeus/upload.do?logType=$2&userName=cloud&type=cmd&filename=$logFile&fix=true"  --post-file $logPath/$logFile --header="Content-Type:multipart/form-data;boundary=---------------------------7d33a816d302b6"
        rm ./upload.do*
}

if [ $dateHour -eq  04 ];then
   file    $logName  $logFile04
   upload  $logFile04 $Date
elif [ $dateHour -eq  16 ];then
   file    $logName $logFile16 
   upload  $logFile16 $Date
else
   file    $logName-$dateYes $logFile
   upload  $logFile $dateYes
fi
