#!/bin/bash
# This script starts Snoopy
#
# Run with command:
#    sudo bash ./start_snoopy.sh > /dev/null &

DEV_NAME=""
DEV_LOC=""

if [ ! -f "$PWD/.DeviceName" ]; then
    echo "ERROR!"
    echo "Please make sure that the file '$PWD/.DeviceName' exists and contains a meaningful name for this device."
    exit;
else
    DEV_NAME=`cat "$PWD/.DeviceName"`;
fi

if [ ! -f "$PWD/.DeviceLoc" ]; then
    echo "ERROR!"
    echo "Please make sure that the file '$PWD/.DeviceLoc' exists and contains a meaningful location for this device."
    exit;
else
    DEV_LOC=`cat "$PWD/.DeviceLoc"`;
fi

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon`;

sudo snoopy -v -m wifi:iface=$IFACE -m sysinfo -m heartbeat -d $DEV_NAME -l "$DEV_LOC" &  echo $! > /tmp/Snoopy/Snoopy.pid
# sudo snoopy -v -m wifi:mon=true -m sysinfo -m heartbeat -d "$DEV_NAME" -l "$DEV_LOC" &  echo $! > /tmp/Snoopy/Snoopy.pid
# airodump &  echo $! > /tmp/Snoopy/Snoopy.pid
