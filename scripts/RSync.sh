SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)
USER="snoopy"
SERVER=`cat ${SNOOP_DIR}/.server`
DEVICE=`cat ${SNOOP_DIR}/.DeviceName`
LOCATION=`cat ${SNOOP_DIR}/.DeviceLoc`



IFACE=$(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan);

IPs="`date +%F' '%T`
Remote: $(dig +short myip.opendns.com @resolver1.opendns.com)
Local: $(ifconfig $IFACE | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1)
"
echo "${IPs}" | ssh -F /home/pi/.ssh/config "${SERVER}" "cat > /home/${USER}/${LOCATION}/${DEVICE}/IP.log"

ssh -F /home/pi/.ssh/config "${SERVER}" mkdir -p "/home/snoopy/${LOCATION}/${DEVICE}/"
rsync -a -e 'ssh -F /home/pi/.ssh/config' "${SNOOP_DIR}/OldDBs/" "${SERVER}:/home/${USER}/${LOCATION}/${DEVICE}"
