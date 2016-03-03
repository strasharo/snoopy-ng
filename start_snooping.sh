#!/bin/bash
#
# This script starts Snoopy

RET_DIR="$PWD";
SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)
cd $SNOOP_DIR;

DEV_NAME=""
DEV_LOC=""

if [ ! -f "./.DeviceName" ]; then
    echo "ERROR!"
    echo "Please make sure that the file '$SNOOP_DIR/.DeviceName' exists and contains a meaningful name for this device."
    exit -1;
fi

if [ ! -f "./.DeviceLoc" ]; then
    echo "ERROR!"
    echo "Please make sure that the file '$SNOOP_DIR/.DeviceLoc' exists and contains a meaningful location for this device."
    exit -1;
fi

DEV_NAME=$(cat "$SNOOP_DIR/.DeviceName");
DEV_LOC=$(cat "$SNOOP_DIR/.DeviceLoc");

IFACE=$(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon);
sudo rm /tmp/Snoopy/*

if [ ! -f "./.WigleUser" ] || [ ! -f "./.WiglePass" ] || [ ! -f "./.WigleEmail" ]; then
    sudo snoopy -v -m wifi:iface=$IFACE -d "$DEV_NAME" -l "$DEV_LOC" -k "$DEV_NAME" &  echo $! > /tmp/Snoopy/Snoopy.pid
    # sudo snoopy -v -m wifi:iface=$IFACE -m sysinfo -m heartbeat -d $DEV_NAME -l "$DEV_LOC" &  echo $! > /tmp/Snoopy/Snoopy.pid
else
    WIG_U=$(cat ./.WigleUser);
    WIG_P=$(cat ./.WiglePass);
    WIG_E=$(cat ./.WigleEmail);
    sudo snoopy -v -m wifi:iface=$IFACE -m wigle:username="$WIG_U",password="$WIG_P",email="$WIG_E" -m sysinfo -m heartbeat -d "$DEV_NAME" -l "$DEV_LOC" &  echo $! > /tmp/Snoopy/Snoopy.pid
fi

cd $RET_DIR;