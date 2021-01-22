#!/bin/bash
#Just finished the system, no need to restore
if [ ! -d "./.system_backup" ]; then
echo "The system is the original version and does not need to be restored"
exit
fi

if [ -d /etc/X11/xorg.conf.d ]; then
sudo rm -rf /etc/X11/xorg.conf.d
fi
if [ -d ./.system_backup/xorg.conf.d ]; then
sudo cp -rf ./.system_backup/xorg.conf.d /etc/X11
if [ -f ./.system_backup/99-calibration.conf ]; then
sudo cp -rf ./.system_backup/99-calibration.conf /etc/X11/xorg.conf.d
fi
if [ -f ./.system_backup/40-libinput.conf ]; then
sudo cp -rf ./.system_backup/40-libinput.conf /etc/X11/xorg.conf.d
fi
fi

result=`grep -rn "^dtoverlay=" /boot/config.txt | grep ":rotate=" | tail -n 1`
if [ $? -eq 0 ]; then
str=`echo -n $result | awk -F: '{printf $2}' | awk -F= '{printf $NF}'`
sudo rm -rf /boot/overlays/$str-overlay.dtb
sudo rm -rf /boot/overlays/$str.dtbo
fi
ls -al ./.system_backup/*.dtb > /dev/null 2>&1 && sudo cp -rf ./.system_backup/*.dtb  /boot/overlays/
ls -al ./.system_backup/*.dtbo > /dev/null 2>&1 && sudo cp -rf ./.system_backup/*.dtbo  /boot/overlays/

if [ -f ./.system_backup/99-fbturbo.conf ];then
sudo cp -rf ./.system_backup/99-fbturbo.conf /usr/share/X11/xorg.conf.d
fi
sudo cp -rf ./.system_backup/cmdline.txt /boot/
sudo cp -rf ./.system_backup/config.txt /boot/
sudo cp -rf ./.system_backup/rc.local /etc/
sudo cp -rf ./.system_backup/modules /etc/

if [ -f /etc/inittab ]; then
sudo rm -rf /etc/inittab
fi
if [ -f ./.system_backup/inittab ]; then
sudo cp -rf ./.system_backup/inittab  /etc
fi

if [ -f /etc/modprobe.d/fbtft.conf ]; then
sudo rm -rf /etc/modprobe.d/fbtft.conf
fi
if [ -f ./.system_backup/fbtft.conf ]; then
sudo cp -rf ./.system_backup/fbtft.conf  /etc/modprobe.d
fi

type fbcp > /dev/null 2>&1
if [ $? -eq 0 ]; then
sudo rm -rf /usr/local/bin/fbcp
fi
if [ -f ./.system_backup/have_fbcp ]; then
sudo install ./rpi-fbcp/build/fbcp /usr/local/bin/fbcp
fi

#type cmake > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#sudo apt-get purge cmake -y 2> error_output.txt
#result=`cat ./error_output.txt`
#echo -e "\033[31m$result\033[0m"
#fi
#if [ -f ./.system_backup/have_cmake ]; then
#sudo apt-get install cmake -y 2> error_output.txt
#result=`cat ./error_output.txt`
#echo -e "\033[31m$result\033[0m"
#fi

if [ -f /usr/share/X11/xorg.conf.d/10-evdev.conf ]; then
sudo dpkg -P xserver-xorg-input-evdev
#sudo apt-get purge xserver-xorg-input-evdev -y 2> error_output.txt
#result=`cat ./error_output.txt`
#echo -e "\033[31m$result\033[0m"
fi
if [ -f ./.system_backup/10-evdev.conf ]; then
sudo dpkg -i -B ./xserver-xorg-input-evdev_1%3a2.10.6-1+b1_armhf.deb
#sudo apt-get install xserver-xorg-input-evdev -y 2> error_output.txt
#result=`cat ./error_output.txt`
#echo -e "\033[31m$result\033[0m"
fi

if [ -f /usr/share/X11/xorg.conf.d/45-evdev.conf ]; then
sudo rm -rf /usr/share/X11/xorg.conf.d/45-evdev.conf
fi
if [ -f ./.system_backup/45-evdev.conf ]; then
sudo cp -rf ./.system_backup/45-evdev.conf /usr/share/X11/xorg.conf.d
fi

if [ -f ./.have_installed ]; then
sudo rm -rf ./.have_installed
fi
if [ -f ./.system_backup/.have_installed ]; then
sudo cp -rf ./.system_backup/.have_installed ./
fi

sudo sync
sudo sync 

cp /boot/config.txt /boot/tmp.txt

sed  -i "/hdmi_force_hotplug=1/d" /boot/tmp.txt
sed  -i "/dtoverlay=vc4-fkms-v3d/d" /boot/tmp.txt
sed  -i "/dtparam=i2c_arm=on/d" /boot/tmp.txt
sed  -i "/dtparam=spi=on/d" /boot/tmp.txt
sed  -i "/enable_uart=1/d" /boot/tmp.txt
sed  -i "/dtoverlay=mhs35:rotate=90/d" /boot/tmp.txt
sed  -i "/hdmi_group=2/d" /boot/tmp.txt
sed  -i "/hdmi_mode=1/d" /boot/tmp.txt
sed  -i "/hdmi_mode=87/d" /boot/tmp.txt
sed  -i "/hdmi_cvt 600 400 60 6 0 0 0=/d" /boot/tmp.txt
sed  -i "/hdmi_drive=2=/d" /boot/tmp.txt

echo "dtoverlay=vc4-fkms-v3d" >> /boot/tmp.txt

cp /boot/tmp.txt /boot/config.txt
rm /boot/tmp.txt

echo "The system has been restored"
echo "now reboot"
sleep 1

sudo reboot
