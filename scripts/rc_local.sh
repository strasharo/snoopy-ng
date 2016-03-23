# Disables the HDMI interface:
/usr/bin/tvservice -o

# Get current time with NTP:
bash $(cat /etc/SNOOP_DIR.conf)/NTP-Sync.sh

# Runs Snoopy:
bash $(cat /etc/SNOOP_DIR.conf)/startup.sh
