# Disables the HDMI interface:
/usr/bin/tvservice -o

# Give ntp a chance to set time (via ethernet)
sleep 5m

# Disable networking daemon
/etc/init.d/networking stop

# Runs Snoopy:
bash "$(cat /etc/SNOOP_DIR.conf)"/startup.sh
