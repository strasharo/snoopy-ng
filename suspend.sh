#!/bin/bash
# This script puts the wireless interface in managed mode, 
#   connects to the WiFi network, transfers the logfile to the remote server, 
#   and suspends the device.
# Make sure to disable wireless in the nm-applet first.

at now + 10 hours -f ./startup.sh

SERVER=<server address for database storage>
NETWORK=<WiFi network to use for database upload>
DATABASE="~/snoopy-ng/snoopy.db"
NODE=`whoami`           # Username should be in the form of "NODE1", "NODE2", etc

sudo kill /tmp/Snoopy/*.pid
#sudo kill ./*.pid

sudo airmon-ng stop `ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep mon`;

IFACE=`ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep wlan`;
sudo ifconfig $IFACE up;

sudo iwconfig $IFACE mode managed;
sudo iwconfig $IFACE essid "${NETWORK}";
sudo dhclient $IFACE;

COUNTER=1;

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
    echo "Database failed to sync. Data will be maintained locally." tee -a ./Database.log

sudo ifconfig $IFACE down;
