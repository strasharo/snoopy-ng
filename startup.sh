#!/bin/bash
# This script puts the wireless interface in monitor mode and starts Snoopy

at 9 PM -f ./suspend.sh         > /dev/null &

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan`;
sudo ifconfig $IFACE down;

nohup bash ./monitor_mode.sh    > /dev/null &
nohup bash ./start_snooping.sh  > /dev/null &