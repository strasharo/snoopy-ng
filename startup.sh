#!/bin/bash
# This script puts the wireless interface in monitor mode and starts Snoopy

read -r -p  "[?] Which battery is being used? ['white' / 'black'] " battery
bash $SNOOP_DIR/uptime.sh &

mkdir -p /tmp/Snoopy/

if [[ `date +%H` -lt 22 ]] && [[ `date +%H` -gt 8 ]]; then
    at 10 PM -f "$SNOOP_DIR/suspend.sh"         > /dev/null &

    sudo bash "$SNOOP_DIR/monitor_mode.sh" > ./monitor.out &

    # Give monitor mode a chance to initailize
    sleep 15;

    sudo bash "$SNOOP_DIR/start_snooping.sh" > ./snooping.out&
else
    $SNOOP_DIR/suspend.sh
fi