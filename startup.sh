#!/bin/bash
# This script puts the wireless interface in monitor mode and starts Snoopy
# Run with
#   nohup bash startup.sh &

SNOOP_DIR="$(cat /etc/SNOOP_DIR.conf)"

mkdir -p /tmp/Snoopy/

NOW="date +%k%M"

if [[ $(eval "$NOW") -le "2200" ]] && [[ "$(eval "$NOW")" -gt "730" ]]; then
    sudo at 10pm    -f "${SNOOP_DIR}/suspend.sh" &

    sudo bash "${SNOOP_DIR}/monitor_mode.sh" >  /dev/null &

    # Give monitor mode a chance to initailize
    sleep 15;

    sudo bash "${SNOOP_DIR}/start_snooping.sh" > /dev/null &
else
    sudo bash "${SNOOP_DIR}/suspend.sh"
fi

