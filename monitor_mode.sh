#!/bin/bash
# This script puts the wireless interface in monitor mode

# Stop any existing interfaces (as a precaution)
IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon`;
if ! [ -z "$IFACE" ]; then
    sudo airmon-ng stop $IFACE;
fi

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan`;
sudo airmon-ng check kill;
sudo airmon-ng start $IFACE;

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon`;

sudo airodump-ng $IFACE & echo $! > /tmp/Snoopy/Airodump.pid
