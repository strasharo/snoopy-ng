$(cat /etc/SNOOP_DIR.conf)/Wifi-Connect.sh

if [ -f /etc/init.d/ntp ]; then
   /etc/init.d/ntp stop
else

echo "[+] Setting time with ntp"
ntpdate ntp.ubuntu.com
/etc/init.d/ntp start
