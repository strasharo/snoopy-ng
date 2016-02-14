#!/bin/bash
# This script puts the wireless interface in monitor mode

GET_IFACES="ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep";

# Power on the USB bus
echo 1 > /sys/devices/platform/bcm2708_usb/buspower;
sleep 2;

# Stop any existing interfaces (as a precaution)
IFACE=$(eval "${GET_IFACES} mon");
if ! [ -z "$IFACE" ]; then
    sudo airmon-ng stop $IFACE;
fi

IFACE=$(eval "${GET_IFACES} wlan");
sudo airmon-ng check kill;
sudo airmon-ng start $IFACE;

IFACE=$(eval "${GET_IFACES} mon");
sudo airodump-ng $IFACE & echo $! > /tmp/Snoopy/Airodump.pid