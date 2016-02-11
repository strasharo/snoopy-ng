#!/bin/bash
# This script puts the wireless interface in managed mode,
#   connects to the WiFi network, transfers the logfile to the remote server,
#   and suspends the device.
#
# Make sure to disable wireless in the nm-applet first.

RET_DIR="$PWD";
cd $SNOOP_DIR;

at now +10 hours -f ./startup.sh

USER="woodstock"
SERVER="<server address for database storage>"
NETWORK="<WiFi network to use for database upload>"
DATABASE="./snoopy.db"
DEVICE=`cat ./.DeviceName`
LOCATION=`cat ./.DeviceLoc`

# This triggers soft shutdown procedure
touch /tmp/Snoopy/STOP_SNIFFING

# Give sub-processes a chance to clean things up...
sleep 1m 

sudo kill -KILL $(cat /tmp/Snoopy/Airodump.pid)

# Any straggling processes:
SNOOP=$(ps -aux | grep snoopy   | grep -v grep | awk '{print $2}' | sed ':a;N;$!ba;s/\n/ /g');
AIRNG=$(ps -aux | grep airodump | grep -v grep | awk '{print $2}' | sed ':a;N;$!ba;s/\n/ /g');
sudo kill -s KILL $AIRNG $SNOOP

sudo airmon-ng stop `ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon`;

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan`;
sudo ifconfig $IFACE up;

sudo iwconfig $IFACE mode managed;
# sudo iwconfig $IFACE essid "${NETWORK}";
sudo dhclient $IFACE;

# 'COUNTER' value is overset only during testing. (Should be reduced to '1' for final deployment.)
let COUNTER=5;
# let COUNTER=1;

while [  $COUNTER -lt 4 ]; do
    if [ scp $DATABASE "${USER}@${SERVER}:/home/${USER}/${LOCATION}/${DEVICE}" -eq 0 ]; then
        rm $DATABASE;
        let COUNTER=10;
    else
        sleep 30;
        let COUNTER=COUNTER+1;
    fi
done

if [ $COUNTER -eq 10 ]; then
    echo "Database synced successfully." | tee -a ./Database.log
else
    filename=$(basename "$DATABASE");
    ext="${filename##*.}";
    filename="${filename%.*}";

    NOW=$(date +%F@%T);
    echo "[${NOW}] :: Database failed to sync. Data will be maintained locally." | tee -a ./Database.log
    mv $DATABASE "$(dirname "$DATABASE")/${filename}_${NOW}.${ext}";
fi

sudo rm -f /tmp/Snoopy/*

sudo ifconfig $IFACE down;

cd "$RET_DIR"