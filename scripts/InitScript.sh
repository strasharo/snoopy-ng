#!/bin/sh

# Disables the HDMI interface:
/usr/bin/tvservice -o

# Runs Snoopy:
bash "${SNOOP_DIR}/startup.sh"