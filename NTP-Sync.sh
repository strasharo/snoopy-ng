#!/bin/bash
#
# This script starts Snoopy

ifup $(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan);

echo "[+] Setting time with ntp"
ntpdate ntp.ubuntu.com
/etc/init.d/ntp start
