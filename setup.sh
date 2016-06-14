echo -n "Enter the new hostname of your board and press [ENTER]: "
read newhostname

sed -ri "s/lime2/$newhostname/g" /etc/hostname
sed -ri "s/localhost lime2/localhost $newhostname/g" /etc/hosts

echo -n "Enter the IP you want for the WLAN interface (i.e. 192.168.10.1) and press [ENTER]: "
read ip
cp interfaces.ap /etc/network/
sed -ri "s/_IPRANGE/$ip/g" /etc/network/interfaces.ap
rm /etc/network/interfaces
ln -s  /etc/network/interfaces.ap  /etc/network/interfaces

echo -n "Starting upgrade..."
apt-mark hold linux-image-next-sunxi linux-dtb-next-sunxi linux-headers-next-sunxi linux-firmware-image-next-sunxi linux-jessie-root-next-lime2 linux-u-boot-lime2-next
apt-get update
apt-get -y upgrade
apt-get -y install dnsmasq
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
sed -ri 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
sh -c "iptables-save > /etc/iptables.ipv4.nat"

echo 'up iptables-restore < /etc/iptables.ipv4.nat' >> /etc/network/interfaces.ap
update-rc.d dnsmasq enable

echo -n "You can now reboot the board with the command 'sudo reboot'!"
