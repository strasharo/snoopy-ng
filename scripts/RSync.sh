SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)
USER="snoopy"
SERVER=`cat ${SNOOP_DIR}/.server`
DEVICE=`cat ${SNOOP_DIR}/.DeviceName`
LOCATION=`cat ${SNOOP_DIR}/.DeviceLoc`


ssh -F /home/pi/.ssh/config "${SERVER}" mkdir -p "/home/snoopy/${LOCATION}/${DEVICE}/"

rsync -a -e 'ssh -F /home/pi/.ssh/config' "${SNOOP_DIR}/OldDBs/" "${SERVER}:/home/${USER}/${LOCATION}$
