#!/bin/bash
if [[ $(id -u) -ne 0 ]] 
then
  echo Run as root
  exit 0
fi

echo Setting ntp 
timedatectl set-ntp true

echo Checking timedatctl status
timedatectl status

echo setting timezone to Europe/Brussels
ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime

echo setting hwclock
hwclock --systohc

echo editing local.gen with en_US.UTF-8 and be_NL.UTF-8
if [[ $(grep ^en_US.UTF-8 /etc/locale.gen) ]]; then
    sed -i 's/^#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
else    
    echo en_US.UTF-8 already enabled
fi
if [[ $(grep ^be_NL.UTF-8 /etc/locale.gen) ]]; then
    sed -i 's/^#be_NL.UTF-8/be_NL.UTF-8/g' /etc/locale.gen
else
    echo be_NL.UTF-8 already enabled
fi

echo generating locales
locale-gen

echo setting keyboard layout to be-latin1
echo "KEYMAP=be-latin1" > /etc/vconsole.conf

echo Creating new initramfs
mkinitcpio -P

