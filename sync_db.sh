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
sudo ifup $IFACE;

if [ -f "$DATABASE" ]; then
    let COUNTER=1;

    ssh "${SERVER}" mkdir -p "/home/snoopy/${LOCATION}/${DEVICE}/"

    while [ $COUNTER -lt 4 ]; do
        if [ scp $DATABASE "${SERVER}:/home/${USER}/${LOCATION}/${DEVICE}" -eq 0 ]; then

            IPs="
Remote: $(dig +short myip.opendns.com @resolver1.opendns.com)
Local: $(ifconfig $IFACE | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1)
"
            ssh "${SERVER}" 'echo "${IPs}" >> /home/${USER}/${LOCATION}/${DEVICE}/IP.log'

            let COUNTER=10;
        else
            sleep 30;
            let COUNTER=COUNTER+1;
        fi
    done

    NOW=$(date +%F@%T);

    if [ $COUNTER -eq 10 ]; then
        echo "Database synced successfully." | tee -a ./Database.log
    else
        echo "[${NOW}] :: Database failed to sync. Data will still be maintained locally." | tee -a ./Database.log
    fi

    filename=$(basename "$DATABASE");
    ext="${filename##*.}";
    filename="${filename%.*}";

    mv $DATABASE "$(dirname "$DATABASE")/${filename}_${NOW}.${ext}";

    sudo rm -f /tmp/Snoopy/*
fi
