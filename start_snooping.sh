#!/bin/bash
# This script starts Snoopy 
#   Modules loaded: Wifi, SysInfo, and Heartbeat


DEV_NAME=""
DEV_LOC=""

if [ ! -f "$SNOOP_DIR/.DeviceName" ]; then
    echo "ERROR!"
    echo "Please make sure that the file '$SNOOP_DIR/.DeviceName' exists and contains a meaningful name for this device."
    exit;
else
    DEV_NAME=`cat "$SNOOP_DIR/.DeviceName"`;
fi

if [ ! -f "$SNOOP_DIR/.DeviceLoc" ]; then
    echo "ERROR!"
    echo "Please make sure that the file '$SNOOP_DIR/.DeviceLoc' exists and contains a meaningful location for this device."
    exit;
else
    DEV_LOC=`cat "$SNOOP_DIR/.DeviceLoc"`;
fi

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon`;

sudo rm /tmp/Snoopy/*
sudo snoopy -v -m wifi:iface=$IFACE -m sysinfo -m heartbeat -d $DEV_NAME -l "$DEV_LOC" &  echo $! > /tmp/Snoopy/Snoopy.pid
