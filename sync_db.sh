#!/bin/bash
# This script puts the wireless interface in managed mode,
#   connects to the WiFi network, transfers the logfile to the remote server

SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)
cd $SNOOP_DIR;

USER="snoopy"
SERVER=`cat ${SNOOP_DIR}/.server`
DATABASE="${SNOOP_DIR}/snoopy.db"
DEVICE=`cat ${SNOOP_DIR}/.DeviceName`
LOCATION=`cat ${SNOOP_DIR}/.DeviceLoc`

# This triggers soft shutdown procedure
sudo touch /tmp/Snoopy/STOP_SNIFFING

# Give sub-processes a chance to clean things up...
sleep 1m

if [ -f /tmp/Snoopy/Airodump.pid ]; then
    sudo kill -s KILL $(cat /tmp/Snoopy/Airodump.pid)
fi

if [ -f /tmp/Snoopy/Snoopy.pid ]; then
    sudo kill $(cat /tmp/Snoopy/Snoopy.pid)
fi

# Any straggling processes:
# SNOOP=$(ps -aux | grep snoopy   | grep -v grep | awk '{print $2}' | sed ':a;N;$!ba;s/\n/ /g');
AIRNG=$(ps -aux | grep airodump | grep -v grep | awk '{print $2}' | sed ':a;N;$!ba;s/\n/ /g');
sudo kill -s KILL $AIRNG #SNOOP

sudo airmon-ng stop $(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon);

if [ -f "$DATABASE" ]; then
    NOW=$(date +%F@%T);

    filename=$(basename "$DATABASE");
    ext="${filename##*.}";
    filename="${filename%.*}";

    mkdir -p "${SNOOP_DIR}/OldDBs"
    DATABASE="OldDBs/${filename}_${NOW}.${ext}";
    mv "${SNOOP_DIR}/snoopy.db" "${SNOOP_DIR}/$DATABASE"

    sudo rm -f /tmp/Snoopy/*
fi
# sudo shutdown -r