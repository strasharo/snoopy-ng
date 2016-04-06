#!/bin/bash
# This script calls the backup.sh script and suspends the device.

SNOOP_DIR="$(cat /etc/SNOOP_DIR.conf)"
cd $SNOOP_DIR;

sudo at 8am -f "${SNOOP_DIR}/startup.sh"

DATABASE="${SNOOP_DIR}/snoopy.db"

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

    DATABASE="${filename}_${NOW}.${ext}";
    mv "${SNOOP_DIR}/snoopy.db" "${SNOOP_DIR}/$DATABASE"

    sudo rm -f /tmp/Snoopy/*
fi

IFACE=$(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan);
sudo ifdown $IFACE;