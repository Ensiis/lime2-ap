echo -n "Enter the new sudo user we are going to create and press [ENTER]: "
read newuser
adduser $newuser
echo "$newuser ALL=(ALL:ALL) ALL" > /etc/sudoers.d/$newuser

echo "Choose a new password for the root user: "
passwd root

echo -n "Enter the new hostname of your board and press [ENTER]: "
read newhostname

sed -ri "s/A20-OLinuXino/$newhostname/g" /etc/hostname
#sed -ri "s/A20-OLinuXino/$newhostname/g" /etc/hosts
echo "127.0.0.1 localhost" > /etc/hosts

echo -n "The board is going to be rebooted when you press [enter], and then the partition will be extended. When the board has rebooted, please connect with your new user, and remove the user olimex for security reasons: sudo deluser olimex"
read enter
echo -n "Resizing "
cd /root
./resize_sd.sh /dev/mmcblk0 2