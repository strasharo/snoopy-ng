#!/bin/bash
# This script puts the wireless interface in monitor mode and starts Snoopy

at 10 PM -f "$SNOOP_DIR/suspend.sh"         > /dev/null &

# IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan`;
# sudo ifconfig $IFACE down;

mkdir -p /tmp/Snoopy/

sudo bash "$SNOOP_DIR/monitor_mode.sh" > ./monitor.out &

# Give monitor mode a chance to initailize
sleep 15;

sudo bash "$SNOOP_DIR/start_snooping.sh" > ./snooping.out&
