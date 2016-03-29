#!/bin/bash
#
# This script starts Snoopy

# Need to ensure Wifi-Connect works properly before proceeding
exit 0;

ifup $(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan);

echo "[+] Setting time with ntp"
ntpdate ntp.ubuntu.com
/etc/init.d/ntp start
