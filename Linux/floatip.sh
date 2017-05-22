#!/usr/bin/env bash

#
# crontab -e
# */1 * * * * floatip.sh >> /tmp/floatip.log 2>&1
#

master='124.158.26.32'
floatip='192.168.76.158'

mask='255.255.255.0'
device='eth0'
source /etc/profile

c1=`ping ${master} -c 1 | grep Unreachable | wc -l`
c2=`ping ${master} -c 10 | grep Unreachable | wc -l`
c3=`ping ${floatip} -c 10 | grep Unreachable | wc -l`
c4=`ifconfig | grep ${floatip} | wc -l`
if [ $c1 -gt 0 ] ;then
	if [ $c2 -gt 9 ] ;then
		if [ $c3 -gt 9 ] ;then
			ifconfig ${device}:1 ${floatip} netmask ${mask}
			echo "float ip to ${floatip}"
		fi
	fi
	echo "can not connect"
else
	if [ $c4 -gt 0 ] ；then
		ifconfig ${device}:1 127.0.0.1 netmask ${mask}
		echo "reset ip"
	fi
	echo "connection is ok"
fi