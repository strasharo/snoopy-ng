#!/bin/bash
# This script starts Snoopy
#
# Run with command:
#    nohup bash ./start_snoopy.sh > /dev/null &

mkdir -p /tmp/Snoopy;

alias LOCATION='Bedroom'
IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon`;

sudo nohup snoopy -v -m wifi:iface=$IFACE -m sysinfo -m heartbeat -d $HOSTNAME -l "${LOCATION}" &  echo $! > /tmp/Snoopy/Snoopy.pid
