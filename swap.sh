#!/bin/bash

# Author: Rushied Qaied Alwusbay
# Email: rush@wusaby.me
# Version: 0.9
# add or change swap in file

# check of root privilages
if [[ $EUID -ne 0 ]]; then
	root_message="This script must run as root"
	[ -z `command -v zenity` ] && echo "$root_message" || zenity --error --width=400 --text="$root_message"
	exit 2
fi

PATH=$PATH:/sbin

# configure swap
## choose size
if [ -z `command -v zenity` ]; then
	PS3='Choose a swap size (cancel if you have):'
	select SIZE in 4 8 16
	do
	break
	done
else
    SIZE=$(zenity --list --radiolist --column Selection --column branch --text="Choose a swap size 'cancel if you have'" TRUE 4 FALSE 8 False 16)
fi

## calculate available space in desk
if [ -v SIZE ]; then
	AVAIL=$(( `df -BM --output=avail,target | grep -w / | awk '{print $1}' | awk '{ print substr( $0, 1, length($0)-1 ) }'` - ( $SIZE * 1024 )  ))
fi

## add swap
if [ -z "$SIZE" ]; then
	swap_message="add swap passed."
elif [[ "$AVAIL" -lt "1024" ]]; then
	swap_message="check disk capacity."
else
	swapoff --all && rm -rf /swapfile || swap_message="adding swap failed, check memory free."
	fallocate -l "$SIZE"G /swapfile
	chmod 0600 /swapfile
	mkswap /swapfile
	swapon /swapfile && swap_message="adding swap done."
	[ -z `grep -o /swapfile /etc/fstab` ] && echo "# add swapfile 
/swapfile swap swap defaults 0 0" >> /etc/fstab
fi

# reduce swappiness
echo "vm.swappiness = 10" >> /etc/sysctl.conf

## execution message
[ -z `command -v zenity` ] && echo "$swap_message" || zenity --info --width=400 --text="$swap_message"