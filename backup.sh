#!/bin/bash
# This script calls the backup.sh script and suspends the device.

SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)

"${SNOOP_DIR}/sync_db.sh"
"${SNOOP_DIR}/startup.sh"