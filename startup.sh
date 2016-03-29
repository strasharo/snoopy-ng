#!/bin/bash
# This script puts the wireless interface in monitor mode and starts Snoopy
# Run with
#   nohup bash startup.sh &

sudo /usr/bin/tvservice -o

RET_DIR="$PWD";
SNOOP_DIR=$(cat /etc/SNOOP_DIR.conf)
cd $SNOOP_DIR;

mkdir -p /tmp/Snoopy/
time="date +%k%M"

if [[ $(eval "$time") -le "2200" ]] && [[ "$(eval "$time")" -gt "730" ]]; then
    at 1:45 PM  -f ./backup.sh  > /dev/null &
    at 7 PM     -f ./backup.sh  > /dev/null &
    at 10 PM    -f ./suspend.sh > /dev/null &

    sudo bash ./monitor_mode.sh > /dev/null &

    # Give monitor mode a chance to initailize
    sleep 15;

    sudo bash ./start_snooping.sh > ./snooping.out&
else
    sudo bash ./suspend.sh
fi

cd $RET_DIR