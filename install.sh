#!/bin/bash
# Basic installation script for Snoopy NG requirements
# glenn@sensepost.com // @glennzw
# Todo: Make this an egg.

if [ $# -gt 0 ] && [[ $1 =~ ^([-]*[h?][eE]?[lL]?[pP]?) ]]; then
  echo " ___  _  _  _____  _____  ____  _  _"
  echo "/ __)( \( )(  _  )(  _  )(  _ \( \/ )"
  echo "\__ \ )  (  )(_)(  )(_)(  )___/ \  /"
  echo "(___/(_)\_)(_____)(_____)(__)   (__)"
  echo
  echo "About:"
  echo -e "    This script installs Snoopy and its dependencies.\n"
  echo "Usage:"
  echo "    Help:"
  echo "        bash install -h"
  echo -e "            Display this message\n"
  echo "    Interactive:"
  echo -e "        sudo bash install.sh\n"
  echo "    Automated:"
  echo "        sudo bash install.sh -c"
  echo -e "            Install Aircrack-ng (for client use)\n"
  echo "        sudo bash install.sh -s"
  echo -e "            Don't install Aircrack-ng (for server use)\n"
  echo "        sudo bash install.sh -cW"
  echo -e "            Install Aircrack-ng (for client use, with Wigle)\n"
  exit;
fi

if [[ $EUID != 0 ]]; then
   echo "Please run this script as root or with sudo ('sudo bash $0').";
   exit;
fi

RET_DIR="$PWD";
SNOOP_DIR=$(cd $(dirname $0); pwd -P);
cd $SNOOP_DIR;

if [ ! -f "./.DeviceName" ]; then
   read -r -p  "[?] What is the name for this device? [default: \"woodstock\"] " device
   echo "${device:=woodstock}" > "$SNOOP_DIR/.DeviceName"
fi

if [ ! -f "./.DeviceLoc" ]; then
   read -r -p  "[?] What is the location for this device? [default: \"test\"] " loc
    echo "${loc:=test}" > "$SNOOP_DIR/.DeviceLoc"
fi

if [ ! -f "./.supplicant.conf" ]; then
    read -r -p  "[?] What is the SSID of the WiFi network to use for syncing? " SSID
    read -r -p  "[?] What your identity for the network? " UNAME
    read -r -p -s "[?] What is the PSK to use for the network? " PSK

    PSK=$(echo -n "$PSK" | iconv -t utf16le | openssl md4);
    PSK=$(echo $PSK|cut -d ' ' -f 2)

    WPASUP="
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid=\"${SSID}\"
    priority=1
    proto=RSN
    key_mgmt=WPA-EAP
    pairwise=CCMP
    auth_alg=OPEN
    eap=PEAP
    identity=\"${UNAME}\"
    password=hash:${PSK}
    phase1=\"peaplabel=0\"
    phase2=\"auth=MSCHAPV2\"
}"

  echo "$WPASUP" > "/etc/wpa_supplicant/wpa_supplicant.conf"
  touch "./.supplicant.conf"
fi

if [ ! -f "./.DeviceKey" ]; then
  echo $(< /dev/urandom tr -dc A-Z0-9 | head -c15) > ./.DeviceKey;
fi



if ( [ ! -f "./.WigleUser" ] || [ ! -f "./.WiglePass" ] || [ ! -f "./.WigleEmail" ] ) && ( [ $# -eq 0 ] || [ $1 == "-cW" ] ); then
  echo "[I] Please Note:"
  echo -e "\tIf you wish to use Wigle, your login info will be stored in these files:"
  echo -e "\t\t\"$SNOOP_DIR/.WigleUser\", \"$SNOOP_DIR/.WiglePass\", and \"$SNOOP_DIR/.WigleEmail\"."
  echo -e "\tYou can create or modify these at any time. All must be present in order for 'start_snooping' to launch using the Wigle module.\n"

  read -t 15 -r -p  "[?] Would you like to use Wigle? [y/N] " wigle
  if [[ "${wigle:=n}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    read -r -p  "[?] What is your Wigle username? [optional] " WigUser
    if [ $WigUser ]; then
      echo "$WigUser" > "$SNOOP_DIR/.WigleUser";
      read -r -p  "[?] What is your Wigle password? [optional] " WigPass
      if [ $WigUser ]; then
        echo "$WigPass" > "$SNOOP_DIR/.WiglePass";
        if [ $WigPass ]; then
          read -r -p  "[?] What is your Wigle email? [optional] " WigEm
          if [ $WigEm ]; then
              echo "$WigEm" > "$SNOOP_DIR/.WigleEmail";
          else
            echo "[!] Error, no email entered. Credentials will not be stored at this time."
            rm ./.WigleUser
            rm ./.WiglePass
          fi
        else
         echo "[!] Error, no password entered. Credentials will not be stored at this time."
         rm ./.WigleUser
       fi
      fi
    fi
  else
    echo -e "\n[I] Skipping Wigle configuration for now."
  fi
fi

set -e

# In case this is the seconds time user runs setup, remove prior symlinks:
rm -f /usr/bin/sslstrip_snoopy
rm -f /usr/bin/snoopy
rm -f /usr/bin/snoopy_auth
rm -f /etc/transforms

echo "[+] Updating repository..."
apt-get update

apt-get install --force-yes --yes ntpdate

#if ps aux | grep ntp | grep -qv grep; then
if [ -f /etc/init.d/ntp ]; then
   /etc/init.d/ntp stop
else
   # Needed for Kali Linux build on Raspberry Pi
   apt-get install ntp
   /etc/init.d/ntp stop
fi
echo "[+] Setting time with ntp"
ntpdate ntp.ubuntu.com
/etc/init.d/ntp start

echo "[+] Setting timzeone..."
echo "America/New_York" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
echo "[+] Installing sakis3g..."
cp ./includes/sakis3g /usr/local/bin

# Packages
echo "[+] Installing required packages..."
apt-get install --force-yes --yes python-pip python-libpcap python-setuptools autossh python-psutil python2.7-dev libpcap0.8-dev ppp at tcpdump dnsutils\
  python-serial sqlite3 python-requests iw build-essential python-bluez python-flask python-gps python-dateutil python-dev libxml2-dev libxslt-dev pyrit mitmproxy
# apt-get install --force-yes --yes python-pip python-libpcap python-setuptools autossh python-psutil python2.7-dev libpcap0.8-dev ppp at  \
  # tcpdump python-serial sqlite3 python-requests iw build-essential python-flask python-dateutil python-dev libxml2-dev libxslt-dev pyrit

# Python packages
easy_install pip
easy_install smspdu

pip install sqlalchemy==0.7.4
pip uninstall requests -y
pip install -Iv https://pypi.python.org/packages/source/r/requests/requests-0.14.2.tar.gz   #Wigle API built on old version
pip install httplib2
pip install BeautifulSoup
pip install publicsuffix
pip install pyinotify
pip install netifaces
pip install dnslib

#Install SP sslstrip
cp -r ./setup/sslstripSnoopy/ /usr/share/
ln -s /usr/share/sslstripSnoopy/sslstrip.py /usr/bin/sslstrip_snoopy

# Download & Installs
echo "[+] Installing pyserial 2.6"
pip install https://pypi.python.org/packages/source/p/pyserial/pyserial-2.6.tar.gz

echo "[+] Downloading pylibpcap..."
pip install https://sourceforge.net/projects/pylibpcap/files/latest/download?source=files#egg=pylibpcap

echo "[+] Downloading dpkt..."
pip install dpkt

echo "[-] Removing default version of scapy..."
apt-get remove -y --force-yes python-scapy
if ! [ -z "$(pip list | grep "scapy")" ]; then
  pip uninstall -y -q scapy;
fi

echo "[+] Installing patched version of scapy..."
pip install ./setup/scapy-latest-snoopy_patch.tar.gz

# Only run this on your client, not server:
if [ $# -ne 0 ]; then
  if [[ $1 == "-c" ]]; then
      response="yes";
  elif [[ $1 == "-s" ]]; then
      response="no";
  fi
else
  read -r -p  "[?] Do you want to download, compile, and install Aircrack-ng? [Y/n] " response
  response="${response:=yes}" # Default to 'yes'
fi

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
  echo "[+] Installing required packages..."
  apt-get install --force-yes --yes subversion libssl-dev libnl-genl-3-dev ethtool pkg-config rfkill
  echo "[+] Downloading aircrack-ng..."
  svn co http://svn.aircrack-ng.org/trunk/ aircrack-ng
  cd aircrack-ng
  echo "[-] Making aircrack-ng"
  make
  echo "[-] Installing aircrack-ng"
  make install
  airodump-ng-oui-update
  cd ../
  rm -rf aircrack-ng
fi

echo "[+] Creating symlinks to this folder for snoopy.py."
echo "sqlite:///${SNOOP_DIR}/snoopy.db" > ./transforms/db_path.conf

ln -s "${SNOOP_DIR}/transforms" /etc/transforms
ln -s "${SNOOP_DIR}/snoopy.py" /usr/bin/snoopy
ln -s "${SNOOP_DIR}/includes/auth_handler.py" /usr/bin/snoopy_auth
chmod +x /usr/bin/snoopy
chmod +x /usr/bin/snoopy_auth
chmod +x /usr/bin/sslstrip_snoopy
chmod +x "${SNOOP_DIR}"/*.sh
echo "${SNOOP_DIR}" > /etc/SNOOP_DIR.conf

# Single-line solution doesn't yet work:
# sed -i 's|^exit 0.*$|$(cat ${SNOOP_DIR}/scripts/rc_local.sh)\n\nexit 0|' /etc/rc.local

if ! [[ -z $(tail -n 1 /etc/rc.local | grep "exit 0") ]]; then
  sed -i '$ d' /etc/rc.local # Remove exit command
fi

echo 'bash $(cat /etc/SNOOP_DIR.conf)/scripts/rc_local.sh' >> /etc/rc.local
echo -e "\nexit 0" >> /etc/rc.local

# # Disable networking daemon
# update-rc.d networking remove

echo "[+] Diabling LEDs."
chmod -R 777 /sys/class/leds/led0
echo 1 > /sys/class/leds/led0/brightness
echo none > /sys/class/leds/led0/trigger

echo
echo "[+] Done!"
echo "[I] Remember to configure your ssh for passwordless authentication and to place the name of your server in:"
echo -e "\t ${PWD}/.server"
echo "[I] You can run snoopy by running:"
echo -e "\t ${PWD}/startup.sh"
echo "    or restarting the device."
echo "[I] Ensure you set your ./transforms/db_path.conf path correctly when using Maltego"

cd $RET_DIR

# NOTE:
#   This is only intended for use in part of a class project.
#   Please ccomment out the following line unless you are are already intricately familiar with this software and its liscencing policies:
echo "Accepted" > ${SNOOP_DIR}/.acceptedlicense