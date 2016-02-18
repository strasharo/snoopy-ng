#!/bin/bash
#
# This script starts Snoopy

# Need to ensure Wifi-Connect works properly before proceeding
exit 0;


$(cat /etc/SNOOP_DIR.conf)/WiFi-Connect.sh

echo "[+] Setting time with ntp"
ntpdate ntp.ubuntu.com
/etc/init.d/ntp start
