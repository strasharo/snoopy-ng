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

if ( [ ! -f "./.WigleUser" ] || [ ! -f "./.WiglePass" ] || [ ! -f "./.WigleEmail" ] ) && ( [ $# -eq 0 ] || [ $1 == "-c" ] ); then
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
apt-get install --force-yes --yes python-pip python-libpcap python-setuptools autossh python-psutil python2.7-dev libpcap0.8-dev ppp at tcpdump \
  python-serial sqlite3 python-requests iw build-essential python-bluez python-flask python-gps python-dateutil python-dev libxml2-dev libxslt-dev pyrit mitmproxy

# Python packages
easy_install pip
easy_install smspdu

pip install sqlalchemy==0.7.4
pip uninstall requests -y
pip install -Iv https://pypi.python.org/packages/source/r/requests/requests-0.14.2.tar.gz   #Wigle API built on old version
pip install httplib2
pip install BeautifulSoup
pip install publicsuffix
#pip install mitmproxy
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
   # airodump-ng-oui-update
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
echo -e "chmod +x \"${SNOOP_DIR}\"/*.sh"
chmod +x "${SNOOP_DIR}"/*.sh

echo "[+] Adding a link to this folder to your bashrc file."
if [[ -z $(cat ${HOME}/.bashrc | grep snoopy_alias) ]]; then
  echo -e "\n. ./.snoopy_alias\n" >> ${HOME}/.bashrc
fi
echo -e "\nexport alias SNOOP_DIR='${SNOOP_DIR}'\n" > ~/.snoopy_alias
echo -e "\nfunction startup { nohup bash ${SNOOP_DIR}/startup.sh & }" >> ~/.snoopy_alias

echo "[+] Modifying your 'rc.local' file to run Snoopy at boot."
AlterRC=false
if [ -f /etc/rc.local_pre-snoopy.bak ]; then
  # If a backup does exist, restore it.
  cp /etc/rc.local{_pre-snoopy.bak,}
else
  # If no backup exists, make one.
  cp /etc/rc.local{,_pre-snoopy.bak}
  AlterRC=true
fi

if ! [[ -z $(tail -n 1 /etc/rc.local | grep "exit 0") ]]; then
  sed -i '$ d' /etc/rc.local # Remove exit command
fi

cat "${SNOOP_DIR}/scripts/rc_local.sh" >> /etc/rc.local
echo -e "\nbash ${SNOOP_DIR}/startup.sh\n" >> /etc/init.d/snoopy
echo "exit 0" >> /etc/init.d/snoopy
chmod 777 /etc/init.d/snoopy

# Disable networking daemon
update-rc.d networking remove

echo "[+] Diabling LEDs."
chmod -R 777 /sys/class/leds/led0
echo 1 >/sys/class/leds/led0/brightness
echo none > /sys/class/leds/led0/trigger

echo "[+] Done. Try run 'snoopy' or 'snoopy_auth'"
echo "[I] Ensure you set your ./transforms/db_path.conf path correctly when using Maltego"
if [ $"AlterRC" = true ]; then
  echo "[I] Changes have been made to the file '/boot/config.txt'. The original version has been backed up to:"
  echo -e "\t /boot.config.txt_pre-snoopy.bak"
fi
echo "[I] Ensure you refresh your bash configuration before running before attempting to use Snoopy."
echo "    You can do this by either starting a new bash session or manually by executing the command:"
echo -e "        source ~/.bashrc"
cd $RET_DIR

# This is only intended for use in part of a class project.
# Please uncomment the following line unless you are are already intricately familiar with this software and its liscencing policies:
echo "Accepted" > ${SNOOP_DIR}/.acceptedlicense