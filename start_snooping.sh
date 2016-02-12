#!/bin/bash
# This script starts Snoopy 
#   Modules loaded: Wifi, SysInfo, Heartbeat, and Wigle (if credentials exist)
#   

RET_DIR="$PWD";
cd $SNOOP_DIR;

DEV_NAME=""
DEV_LOC=""

if [ ! -f "./.DeviceName" ]; then
    echo "ERROR!"
    echo "Please make sure that the file '$SNOOP_DIR/.DeviceName' exists and contains a meaningful name for this device."
    exit;
else
    DEV_NAME=`cat "$SNOOP_DIR/.DeviceName"`;
fi

if [ ! -f "./.DeviceLoc" ]; then
    echo "ERROR!"
    echo "Please make sure that the file '$SNOOP_DIR/.DeviceLoc' exists and contains a meaningful location for this device."
    exit;
else
    DEV_LOC=`cat "$SNOOP_DIR/.DeviceLoc"`;
fi

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon`;
sudo rm /tmp/Snoopy/*

if [ ! -f "./.WigleUser" ] || [ ! -f "./.WiglePass" ] || [ ! -f "./.WigleEmail" ]; then
    sudo snoopy -v -m wifi:iface=$IFACE -d $DEV_NAME -l "$DEV_LOC" &  echo $! > /tmp/Snoopy/Snoopy.pid
    # sudo snoopy -v -m wifi:iface=$IFACE -m sysinfo -m heartbeat -d $DEV_NAME -l "$DEV_LOC" &  echo $! > /tmp/Snoopy/Snoopy.pid
else
    WIG_U=`cat ./.WigleUser`;
    WIG_P=`cat ./.WiglePass`;
    WIG_E=`cat ./.WigleEmail`;
    sudo snoopy -v -m wifi:iface=$IFACE -m wigle:username="$WIG_U",password="$WIG_P",email="$WIG_E" -m sysinfo -m heartbeat -d "$DEV_NAME" -l "$DEV_LOC" &  echo $! > /tmp/Snoopy/Snoopy.pid

cd $RET_DIR;