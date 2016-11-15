#!/bin/bash
#
# This script syncs the time due to snoopy having no onboad clock

ifup $(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan);

echo "[+] Setting time with ntp"
ntpdate bg.pool.ntp.org
/etc/init.d/ntp start
