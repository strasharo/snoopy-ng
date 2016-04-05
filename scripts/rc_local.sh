SNOOP_DIR="$(cat /etc/SNOOP_DIR.conf)"
cd $SNOOP_DIR;

# Disables the HDMI interface:
/usr/bin/tvservice -o

# Get current time with NTP:
bash $SNOOP_DIR/NTP-Sync.sh

# Runs Snoopy:
bash $SNOOP_DIR/startup.sh

