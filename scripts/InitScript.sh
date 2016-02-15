#!/bin/sh
### BEGIN INIT INFO
# Provides:          snooper
# Required-Start:    $local_fs $remote_fs
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Run Snoopy at boot-time
# Description: Run Snoopy at boot-time
### END INIT INFO


case $1 in
 start)
    # Disables the HDMI interface:
    /usr/bin/tvservice -o

# Runs Snoopy:
# i.e. bash "${SNOOP_DIR}/startup.sh"