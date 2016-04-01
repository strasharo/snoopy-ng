#!/bin/bash
# This script calls the backup.sh script and suspends the device.

SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)

sudo bash "${SNOOP_DIR}/sync_db.sh"

sudo reboot now