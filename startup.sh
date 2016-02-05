#!/bin/bash
# This script puts the wireless interface in monitor mode and starts Snoopy

at 10 PM -f `pwd`/suspend.sh         > /dev/null &

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan`;
sudo ifconfig $IFACE down;

mkdir -p /tmp/Snoopy/

nohup bash `pwd`/monitor_mode.sh    > /dev/null &
nohup bash `pwd`/start_snooping.sh  > /dev/null &