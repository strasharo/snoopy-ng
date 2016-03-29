# Disables the HDMI interface:
/usr/bin/tvservice -o

# Get current time with NTP:
bash $(cat /etc/SNOOP_DIR.conf)/NTP-Sync.sh

# Send
echo "date +%F' '%T
Remote: $(dig +short myip.opendns.com @resolver1.opendns.com)
Local: $(ifconfig $IFACE | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1)
" | ssh "${SERVER}" "cat > /home/${USER}/${LOCATION}/${DEVICE}/IP.log"

# Runs Snoopy:
bash $(cat /etc/SNOOP_DIR.conf)/startup.sh

