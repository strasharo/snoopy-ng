#!/bin/bash
# This script calls the backup.sh script and suspends the device.

SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)

sudo bash "${SNOOP_DIR}/sync_db.sh"
sudo airmon-ng check kill

sudo bash ./monitor_mode.sh > /dev/null &
# Give monitor mode a chance to initailize
sleep 15;

sudo bash ./start_snooping.sh > /dev/null &
