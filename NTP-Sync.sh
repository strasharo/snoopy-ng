#!/bin/bash
#
# This script syncs the time due to snoopy having no onboad clock

ifup $(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan);

echo "[+] Setting time with ntp"
ntpdate ntp.ubuntu.com
/etc/init.d/ntp start