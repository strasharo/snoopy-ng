#!/bin/bash
# This script calls the backup.sh script and suspends the device.

SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)

sudo at 8 AM -f "${SNOOP_DIR}/startup.sh" > /dev/null &
sudo bash "${SNOOP_DIR}/sync_db.sh"

IFACE=$(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan);
sudo ifdown $IFACE;