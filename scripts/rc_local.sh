SNOOP_DIR="$(cat /etc/SNOOP_DIR.conf)"
cd $SNOOP_DIR;

# Disables the HDMI interface:
/usr/bin/tvservice -o

# Give ntp a chance to set time (via ethernet)
sleep 5 m

# Disable networking daemon
sudo /etc/init.d/networking stop

# Runs Snoopy:
bash $SNOOP_DIR/startup.sh

