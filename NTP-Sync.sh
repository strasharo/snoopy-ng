#!/bin/bash
#
# This script syncs the time due to snoopy having no onboad clock

ifup $(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan);

echo "[+] Setting time with ntp"
ntpdate ntp.ubuntu.com
/etc/init.d/ntp start

( /etc/init.d/ntp stop
until ping -nq -c3 8.8.8.8; do
   echo "Waiting for network..."
done
ntpdate -s time.nist.gov
/etc/init.d/ntp start )&
