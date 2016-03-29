# Disables the HDMI interface:
/usr/bin/tvservice -o

# Get current time with NTP:
bash $(cat /etc/SNOOP_DIR.conf)/NTP-Sync.sh

# Send IP address info to remote server
if [ -f /etc/SNOOP_DIR.conf ]; then
    SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)
    if [ -f ${SNOOP_DIR}/.server ] && [ -f ${SNOOP_DIR}/.DeviceName ] && [ -f ${SNOOP_DIR}/.DeviceLoc ]
    then
        SERVER=`cat ${SNOOP_DIR}/.server`
        DEVICE=`cat ${SNOOP_DIR}/.DeviceName`
        LOCATION=`cat ${SNOOP_DIR}/.DeviceLoc`

        echo "date +%F' '%T
        Remote: $(dig +short myip.opendns.com @resolver1.opendns.com)
        Local: $(ifconfig $IFACE | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1)
        " | ssh "${SERVER}" "cat > /home/${USER}/${LOCATION}/${DEVICE}/IP.log"
    fi
fi

# Runs Snoopy:
bash $(cat /etc/SNOOP_DIR.conf)/startup.sh

