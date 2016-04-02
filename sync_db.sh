#!/bin/bash
# This script puts the wireless interface in managed mode,
#   connects to the WiFi network, transfers the logfile to the remote server

SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)
cd $SNOOP_DIR;

USER="snoopy"
SERVER=`cat ${SNOOP_DIR}/.server`
DATABASE="${SNOOP_DIR}/snoopy.db"
DEVICE=`cat ${SNOOP_DIR}/.DeviceName`
LOCATION=`cat ${SNOOP_DIR}/.DeviceLoc`

# This triggers soft shutdown procedure
sudo touch /tmp/Snoopy/STOP_SNIFFING

# Give sub-processes a chance to clean things up...
sleep 1m

if [ -f /tmp/Snoopy/Airodump.pid ]; then
    sudo kill -s KILL $(cat /tmp/Snoopy/Airodump.pid)
fi

if [ -f /tmp/Snoopy/Snoopy.pid ]; then
    sudo kill $(cat /tmp/Snoopy/Snoopy.pid)
fi

# Any straggling processes:
# SNOOP=$(ps -aux | grep snoopy   | grep -v grep | awk '{print $2}' | sed ':a;N;$!ba;s/\n/ /g');
AIRNG=$(ps -aux | grep airodump | grep -v grep | awk '{print $2}' | sed ':a;N;$!ba;s/\n/ /g');
sudo kill -s KILL $AIRNG #SNOOP

sudo airmon-ng stop $(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon);

IFACE=$(ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan);
sudo ifconfig $IFACE down
# sudo ifup $IFACE;
sudo killall wpa_supplicant
sudo wpa_supplicant -B -i $IFACE -c /home/pi/wpa.conf
sudo dhcpcd $IFACE

if [ -f "$DATABASE" ]; then
    NOW=$(date +%F@%T);

    filename=$(basename "$DATABASE");
    ext="${filename##*.}";
    filename="${filename%.*}";

    mkdir -p "${SNOOP_DIR}/OldDBs"
    DATABASE="OldDBs/${filename}_${NOW}.${ext}";
    mv "${SNOOP_DIR}/snoopy.db" "${SNOOP_DIR}/$DATABASE"

#     let COUNTER=0;
#     until [ $COUNTER -gt 4 ]; do
#         if $(ping -nq -c3 8.8.8.8); then
#             let COUNTER=10;
#         else
#             echo "[${NOW}] :: Waiting for network..." | tee -a ./Database.log;
#             echo -e "[${NOW}] ::\n$(ifconfig $IFACE)" > ./sync_db--ifconf.log
#             echo -e "[${NOW}] ::\n$(iwconfig $IFACE)" > ./sync_db--iwconf.log
#             let COUNTER=COUNTER+1;
#         fi;
#     done

#     let COUNTER=1;

#     ssh -F /home/pi/.ssh/config "${SERVER}" mkdir -p "/home/snoopy/${LOCATION}/${DEVICE}/"

#     rsync -a -e 'ssh -F /home/pi/.ssh/config' "${SNOOP_DIR}/OldDBs/" "${SERVER}:/home/${USER}/${LOCATION}/${DEVICE}"
#     # scp  -F /home/pi/.ssh/config "${SNOOP_DIR}/${DATABASE}" "${SERVER}:/home/${USER}/${LOCATION}/${DEVICE}"

#     if [ $? -eq 0 ]; then
#         let COUNTER=10;

#         IPs="`date +%F' '%T`
# Remote: $(dig +short myip.opendns.com @resolver1.opendns.com)
# Local: $(ifconfig $IFACE | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1)
# "
#         echo "${IPs}" | ssh -F /home/pi/.ssh/config "${SERVER}" "cat > /home/${USER}/${LOCATION}/${DEVICE}/IP.log"
#     fi

    # if [ $COUNTER -eq 10 ]; then
    #     echo "[${NOW}] :: Database synced successfully." | tee -a ./Database.log
    # else
    #     echo "[${NOW}] :: Database failed to sync. Data will still be maintained locally." | tee -a ./Database.log
    # fi

    sudo rm -f /tmp/Snoopy/*
fi
sudo shutdown -r
# sudo killall wpa_supplicant
# sudo ifdown $IFACE;
