#!/bin/bash

# Author: Rushied Qaied Alwusbay
# Email: rush@wusaby.me
# Version: 0.9
# first config for debian installiation

# check of root privilages
if [[ $EUID -ne 0 ]]; then
	root_message="This script must run as root"
	[ -z `command -v zenity` ] && echo "$root_message" || zenity --error --width=400 --text="$root_message"
	exit 2
fi

PATH=$PATH:/sbin

# add i386 support
dpkg --add-architecture i386

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
AVAIL=$(( `df -BM --output=avail,target | grep -w / | awk '{print $1}' | awk '{ print substr( $0, 1, length($0)-1 ) }'` - ( $SIZE * 1024 )  ))

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

## execution message
[ -z `command -v zenity` ] && echo "$swap_message" || zenity --info --width=400 --text="$swap_message"

# configue repos
## choose branch
if [ -z `command -v zenity` ]; then
	PS3='Choose a branch: '
	# TODO: move code to flaty script
	#options=("stable" "oldstable")
	#select KERNEL in "${options[@]}"
	select KERNEL in stable oldstable current
	do
	#	case $opt in
	#		"stable")
	#			KERNEL=stable
	#			break
	#			;;
	#		"oldstable")
	#			KERNEL=oldstable
	#			break
	#			;;
	#		*) echo "invalid option $REPLY";;
	#	esac
	break
	done
else
    KERNEL=$(zenity --list --radiolist --column Selection --column branch --text="Choose a branch" TRUE stable FALSE oldstable False current)
fi

## excution code for chosen branch
if [ -z "$KERNEL" ]; then
	config_message="configure distro passed."
elif [ "$KERNEL" = current ]; then
	DISTRO=$(lsb_release -cs)
	echo "# distro repos
deb http://deb.debian.org/debian/ $DISTRO main contrib non-free
deb http://deb.debian.org/debian/ $DISTRO-updates main contrib non-free
deb http://deb.debian.org/debian-security/ $DISTRO-security main contrib non-free
deb http://deb.debian.org/debian $DISTRO-backports main contrib non-free" > /etc/apt/sources.list.d/distro.list
	rm -rf /etc/apt/sources.list.d/kernel.list /etc/apt/preferences.d/kernel
	config_message="configure distro done."
else
	echo "# distro repos
deb http://deb.debian.org/debian/ testing main contrib non-free
deb http://deb.debian.org/debian/ testing-updates main contrib non-free
deb http://deb.debian.org/debian-security/ testing-security main contrib non-free" > /etc/apt/sources.list.d/distro.list
	echo "# distro prefrences
Package: *
Pin: release a=testing
Pin-Priority: 700

Package: *
Pin: release a=sid
Pin-Priority: 650

Package: *
Pin: release a=stable
Pin-Priority: 600" > /etc/apt/preferences.d/distro
	# TODO: chheck if `-dkms` need adding to this script
	echo "# kernel repos
deb http://deb.debian.org/debian/ $KERNEL main contrib non-free
deb http://deb.debian.org/debian/ $KERNEL-updates main contrib non-free" > /etc/apt/sources.list.d/kernel.list
	echo "# kernel porefrences
Package: linux-image-*
Pin: release a=$KERNEL
Pin-Priority: 950

Package: linux-headers-*
Pin: release a=$KERNEL
Pin-Priority: 950

Package: linux-libc-*
Pin: release a=$KERNEL
Pin-Priority: 950" > /etc/apt/preferences.d/kernel

	config_message="configure distro done."
fi

## excution message
[ -z `command -v zenity` ] && echo "$config_message" || zenity --info --width=400 --text="$config_message"

## remove sources.list
rm -f /etc/apt/sources.list /etc/apt/sources.list.save

if [ -z `command -v flatpak` ]; then
	[ -z `command -v zenity` ] && echo $'flatpak is not installed \nto install it visit https://flatpak.org/setup/' || zenity --error --width=400 --text="flatpak is not installed \nto install it visit https://flatpak.org/setup/"
	exit 1
else
	flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && zenity --info --text="Add flathub repo done." || zenity --error --text="An error has ocurred, check network."
fi
