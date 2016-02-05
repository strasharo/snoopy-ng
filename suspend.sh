#!/bin/bash
# This script puts the wireless interface in managed mode, 
#   connects to the WiFi network, transfers the logfile to the remote server, 
#   and suspends the device.
# Make sure to disable wireless in the nm-applet first.

at now + 10 hours -f ./startup.sh

SERVER="<server address for database storage>"
NETWORK="<WiFi network to use for database upload>"
DATABASE="~/snoopy-ng/snoopy.db"
NODE=`hostname`           # Hostname should be in the form of "NODE1", "NODE2", etc

# Addition of 'SIGNINT' argument neccessary in order to trigger a safe suspend of the process
#   -- Simulates a keyboard interrupt, triggering Snoopy's controlled shutdown procedure (storing data to the DB, etc)
sudo kill -SIGINT /tmp/Snoopy/*.pid

sudo airmon-ng stop `ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon`;

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan`;
sudo ifconfig $IFACE up;

sudo iwconfig $IFACE mode managed;
# sudo iwconfig $IFACE essid "${NETWORK}";
sudo dhclient $IFACE;

# 'COUNTER' value is overset only during testing. Should be reduced to '1' for final deployment.
let COUNTER=5;
# let COUNTER=1;

while [  $COUNTER -lt 4 ]; do
    if [ scp -P 7900 $DATABASE woodstock@"${SERVER}":/some/remote/directory -eq 0 ]; then
        rm $DATABASE;
        let COUNTER=10;
    else
        sleep 30;
        let COUNTER=COUNTER+1;
    fi
done

if [ $COUNTER -eq 10 ]; then
    echo "Database synced successfully." tee -a ./Database.log
else
    filename=$(basename "$DATABASE");
    ext="${filename##*.}";
    filename="${filename%.*}";

    echo "Database failed to sync. Data will be maintained locally." tee -a ./Database.log
    mv ./$DATABASE "$(dirname "$DATABASE")/${filename}_`date --date='-1 month' +%F@%T`.${ext}";
fi

sudo ifconfig $IFACE down;
