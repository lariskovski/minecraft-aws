#!/bin/bash

proc_time=$(cat /proc/uptime | awk -F "." '{ print $1 }')

if [ $proc_time -gt 1200 ] ; then
	/bin/python3 /home/minecraft/destroy-monitor.py
else
	echo 'lt'
fi
