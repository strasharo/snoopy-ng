#!/bin/bash
# This script puts the wireless interface in monitor mode and starts Snoopy

if [ "$#" -gt 0 ]; then
    read -t 30 -r -p  "[?] Which battery is being used? ['white' / 'black'] " battery
    if ! [ -z $battery ]; then 
        bash $SNOOP_DIR/uptime.sh battery &
    fi
fi

mkdir -p /tmp/Snoopy/
time="date +%k%M"

if [[ $(eval "$time") -le "2200" ]] && [[ "$(eval "$time")" -gt "730" ]]; then
    at 10 PM -f "$SNOOP_DIR/suspend.sh"         > /dev/null &

    sudo bash "$SNOOP_DIR/monitor_mode.sh" > ./monitor.out &

    # Give monitor mode a chance to initailize
    sleep 15;

    sudo bash "$SNOOP_DIR/start_snooping.sh" > ./snooping.out&
else
    $SNOOP_DIR/suspend.sh
fi