#!/bin/bash
#
# Connects the to the WiFi network "$NETWORK"
#   (designed for use with an unsecured network)

NETWORK="<WiFi network to use for database upload>"
IFACE=$(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan);

sudo ifconfig $IFACE up;
sudo iwconfig $IFACE mode managed;
sudo iwconfig $IFACE essid "${NETWORK}" key open;
sudo dhclient $IFACE;

