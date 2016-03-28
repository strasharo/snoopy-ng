#!/bin/bash
# This script puts the wireless interface in monitor mode

GET_IFACES="ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep";

# Disable any existing WiFi connections (WPA_Supplicant, etc)
sudo ifdown $(eval "${GET_IFACES} wlan");
sudo killall wpa_supplicant

# Stop any existing interfaces (as a precaution)
IFACE=$(eval "${GET_IFACES} mon");
if ! [ -z "$IFACE" ]; then
    sudo airmon-ng stop $IFACE;
fi

IFACE=$(eval "${GET_IFACES} wlan");
sudo airmon-ng check kill;
sudo airmon-ng start $IFACE;

IFACE=$(eval "${GET_IFACES} mon");
sudo airodump-ng $IFACE > /dev/null 2>&1 & echo $! > /tmp/Snoopy/Airodump.pid