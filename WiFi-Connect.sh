NETWORK="<WiFi network to use for database upload>"

sudo ifconfig $IFACE up;
sudo iwconfig $IFACE mode managed;
sudo iwconfig $IFACE essid "${NETWORK}";
sudo dhclient $IFACE;

