#!/bin/bash
# Basic installation script for Snoopy NG requirements
# glenn@sensepost.com // @glennzw
# Todo: Make this an egg.

if [ $EUID != 0 ]; then
   sudo "$0" "$@";
fi

set -e
# In case this is the seconds time user runs setup, remove prior symlinks:
sudo rm -f /usr/bin/sslstrip_snoopy
sudo rm -f /usr/bin/snoopy
sudo rm -f /usr/bin/snoopy_auth
sudo rm -f /etc/transforms

echo "[+] Updating repository..."
sudo apt-get update

sudo apt-get install --force-yes --yes ntpdate

#if ps aux | grep ntp | grep -qv grep; then 
if [ -f /etc/init.d/ntp ]; then
   /etc/init.d/ntp stop
else
   # Needed for Kali Linux build on Raspberry Pi
   sudo apt-get install ntp
   sudo /etc/init.d/ntp stop
fi
echo "[+] Setting time with ntp"
ntpdate ntp.ubuntu.com 
/etc/init.d/ntp start

echo "[+] Setting timzeone..."
echo "Etc/UTC" > /etc/timezone
sudo dpkg-reconfigure -f noninteractive tzdata
echo "[+] Installing sakis3g..."
sudo cp ./includes/sakis3g /usr/local/bin

# Packages
echo "[+] Installing required packages..."
sudo apt-get install --force-yes --yes python-pip python-libpcap python-setuptools autossh python-psutil python2.7-dev libpcap0.8-dev ppp tcpdump python-serial sqlite3 python-requests iw build-essential python-bluez python-flask python-gps python-dateutil python-dev libxml2-dev libxslt-dev pyrit mitmproxy

# Python packages

sudo easy_install pip
sudo easy_install smspdu

sudo pip install sqlalchemy==0.7.4
sudo pip uninstall requests -y
sudo pip install -Iv https://pypi.python.org/packages/source/r/requests/requests-0.14.2.tar.gz   #Wigle API built on old version
sudo pip install httplib2
sudo pip install BeautifulSoup
sudo pip install publicsuffix
#sudo pip install mitmproxy
sudo pip install pyinotify
sudo pip install netifaces
sudo pip install dnslib

#Install SP sslstrip
sudo cp -r ./setup/sslstripSnoopy/ /usr/share/
sudo ln -s /usr/share/sslstripSnoopy/sslstrip.py /usr/bin/sslstrip_snoopy

# Download & Installs
echo "[+] Installing pyserial 2.6"
sudo pip install https://pypi.python.org/packages/source/p/pyserial/pyserial-2.6.tar.gz

echo "[+] Downloading pylibpcap..."
sudo pip install https://sourceforge.net/projects/pylibpcap/files/latest/download?source=files#egg=pylibpcap

echo "[+] Downloading dpkt..."
sudo pip install https://dpkt.googlecode.com/files/dpkt-1.8.tar.gz

echo "[+] Installing patched version of scapy..."
sudo pip install ./setup/scapy-latest-snoopy_patch.tar.gz

# Only run this on your client, not server:
read -r -p  "[?] Do you want to download, compile, and install aircrack? [y/n] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
   echo "[+] Installing required packages..."
<<<<<<< HEAD
   sudo apt-get --force-yes --yes subversion libssl-dev libnl-genl-3-dev ethtool rfkill
=======
   apt-get --force-yes --yes subversion libssl-dev libnl-genl-3-dev ethtool rfkill
>>>>>>> c40253e36a1a3b994d02ea3779f7377fee367964
   echo "[+] Downloading aircrack-ng..."
   svn co http://svn.aircrack-ng.org/trunk/ aircrack-ng   tar xzf aircrack-ng-1.2-beta1.tar.gz
   cd aircrack-ng
   echo "[-] Making aircrack-ng"
   make
   echo "[-] Installing aircrack-ng"
   sudo make install
   cd ../
   rm -rf aircrack-ng
fi

echo "[+] Creating symlinks to this folder for snoopy.py."

echo "sqlite:///`pwd`/snoopy.db" > ./transforms/db_path.conf

sudo ln -s `pwd`/transforms /etc/transforms
sudo ln -s `pwd`/snoopy.py /usr/bin/snoopy
sudo ln -s `pwd`/includes/auth_handler.py /usr/bin/snoopy_auth
sudo chmod +x /usr/bin/snoopy
sudo chmod +x /usr/bin/snoopy_auth
sudo chmod +x /usr/bin/sslstrip_snoopy

echo "[+] Done. Try run 'snoopy' or 'snoopy_auth'"
echo "[I] Ensure you set your ./transforms/db_path.conf path correctly when using Maltego"
