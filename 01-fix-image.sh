sed -ri 's/autologin-user/#autologin-user/g' /etc/lightdm/lightdm.conf

echo -n "Starting upgrade..."
apt-get -y remove --purge gnome-* xserver-* desktop-* apache2 crtmpserver  
apt-get -y autoremove  
apt-get update
apt-get -y upgrade
apt-get -y install build-essential libusb-1.0

mkdir /fex
mount /dev/mmcblk0p1 /fex
cp script.fex /root
cd /root
git clone https://github.com/linux-sunxi/sunxi-tools  
cd sunxi-tools
make
#./bin2fex /fex/script.bin > /fex/script.fex
cp /fex/script.bin /fex/script.bin.save
./fex2bin /root/script.fex /fex/script.bin

echo -n "The board is going to be rebooted when you press [enter]. When the board has rebooted, please reconnect."
read enter
reboot