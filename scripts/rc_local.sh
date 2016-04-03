SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)
cd $SNOOP_DIR;

# Disables the HDMI interface:
/usr/bin/tvservice -o

# Get current time with NTP:
( /etc/init.d/ntp stop
until ping -nq -c3 8.8.8.8; do
   echo "Waiting for network..."
done
ntpdate -s time.nist.gov
/etc/init.d/ntp start )&

# Sync
# bash $SNOOP_DIR/scripts/RSync.sh &

# Update Snoopy
bash $SNOOP_DIR/scripts/git_update.sh &

# Runs Snoopy:
bash $SNOOP_DIR/startup.sh

