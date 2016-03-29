# Disables the HDMI interface:
/usr/bin/tvservice -o

# Get current time with NTP:
bash $(cat /etc/SNOOP_DIR.conf)/NTP-Sync.sh

# Send IP address info to remote server
bash $(cat /etc/SNOOP_DIR.conf)/sync_ip.sh

# Runs Snoopy:
bash $(cat /etc/SNOOP_DIR.conf)/startup.sh

