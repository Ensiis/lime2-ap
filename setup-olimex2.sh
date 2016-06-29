echo -n "Enter the new sudo user we are going to create and press [ENTER]: "
read newuser
adduser $newuser
echo "$newuser ALL=(ALL:ALL) ALL" > /etc/sudoers.d/$newuser

echo "Choose a new password for the root user: "
passwd root

echo -n "Enter the new hostname of your board and press [ENTER]: "
read newhostname

sed -ri "s/A20-OLinuXino/$newhostname/g" /etc/hostname
sed -ri "s/A20-OLinuXino/$newhostname/g" /etc/hosts

echo -n "Enter the IP you want for the WLAN interface (i.e. 192.168.10.1) and press [ENTER]: "
read ip
cp interfaces.ap /etc/network/
sed -ri "s/_IPRANGE/$ip/g" /etc/network/interfaces.ap
rm /etc/network/interfaces
ln -s  /etc/network/interfaces.ap  /etc/network/interfaces

echo -n "Enter the start of the IP range used by the DHCP server (i.e. 192.168.10.2) and press [ENTER]: "
read ipstart
echo -n "Enter the end of the IP range used by the DHCP server (i.e. 192.168.10.254) and press [ENTER]: "
read ipend
echo "dhcp-range=interface:wlan0,$ipstart,$ipend,96h" > /etc/dnsmasq.d/wlan0

cp hostapd-ap.conf /etc/
echo -n "Enter the SSID of the Wifi network and press [ENTER]: "
read ssid
sed -ri "s/_SSID/$ssid/g" /etc/hostapd-ap.conf
echo -n "Enter the channel of the Wifi network (number between 1 and 14 included) and press [ENTER]: "
read channel
sed -ri "s/_CHANNEL/$channel/g" /etc/hostapd-ap.conf
echo -n "Enter the password of the Wifi network and press [ENTER]: "
read password
sed -ri "s/_PASSWORD/$password/g" /etc/hostapd-ap.conf

sed -ri 's/DAEMON_CONF=/DAEMON_CONF=\/etc\/hostapd-ap.conf/g' /etc/init.d/hostapd
sed -ri 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd-ap.conf"/g' /etc/default/hostapd
sed -ri 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
sh -c "iptables-save > /etc/iptables.ipv4.nat"

echo 'up iptables-restore < /etc/iptables.ipv4.nat' >> /etc/network/interfaces.ap
update-rc.d dnsmasq enable
update-rc.d hostapd enable

echo -n "The board is going to be rebooted when you press [enter], and then the partition will be extended. When the board has rebooted, please connect with your new user, and remove the user olimex for security reasons: sudo deluser olimex"
read enter

echo -n "Resizing "
cd /root
./resize_sd.sh /dev/mmcblk0 2