#!/bin/bash
# This script starts Snoopy
#
# Run with command:
#    nohup bash ./start_snoopy.sh > /dev/null &

DEV_NAME=""
DEV_LOC=""

if [ ! -f "`pwd`/.DeviceName" ]; then
    echo "ERROR!"
    echo "Please make sure that the file \'`pwd`/.DeviceName\' exists and contains a meaningful name for this device."
    exit;
else
    DEV_NAME=`cat `pwd`/.DeviceName`;
fi

if [ ! -f "`pwd`/.DeviceLoc" ]; then
    echo "ERROR!"
    echo "Please make sure that the file \'`pwd`/.DeviceLoc\' exists and contains a meaningful location for this device."
    exit;
else
    DEV_LOC=`cat `pwd`/.DeviceLoc`;
fi

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon`;

sudo nohup snoopy -v -m wifi:iface=$IFACE -m sysinfo -m heartbeat -d $DEV_NAME -l "$DEV_LOC" &  echo $! > /tmp/Snoopy/Snoopy.pid
# sudo nohup snoopy -v -m wifi:mon=true -m sysinfo -m heartbeat -d "$DEV_NAME" -l "$DEV_LOC" &  echo $! > /tmp/Snoopy/Snoopy.pid
