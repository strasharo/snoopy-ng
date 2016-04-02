set +e

SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)
cd $SNOOP_DIR;

# Disables the HDMI interface:
/usr/bin/tvservice -o

# Get current time with NTP:
bash $SNOOP_DIR/NTP-Sync.sh

# Send IP address info to remote server
bash $SNOOP_DIR/sync_ip.sh

# Update Snoopy
bash $SNOOP_DIR/scripts/git_update.sh

# Runs Snoopy:
bash $SNOOP_DIR/startup.sh

