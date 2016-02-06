#!/bin/bash
# This script puts the wireless interface in monitor mode
#
# Run with command:
#    nohup bash ./startup.sh > /dev/null &

# Stop any existing interfaces (as a precaution)
IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon`;
sudo airmon-ng stop $IFACE;

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan`;
sudo airmon-ng check kill;
sudo airmon-ng start $IFACE;

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon`;

sudo airodump-ng $IFACE & echo $! > /tmp/Snoopy/Airodump.pid
