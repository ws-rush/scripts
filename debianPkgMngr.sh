#!/bin/bash

# Author: Rushied Qaied Alwusbay
# Email: rush@wusaby.com
# Version: 0.9
# configure package manager and distro branch for first time

# check of root privilages
if [[ $EUID -ne 0 ]]; then
	root_message="This script must run as root"
	[ -z `command -v zenity` ] && echo "$root_message" || zenity --error --width=400 --text="$root_message"
	exit 2
fi

PATH=$PATH:/sbin

# add i386 support
dpkg --add-architecture i386

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
Package: linux-*
Pin: release a=$KERNEL
Pin-Priority: 950" > /etc/apt/preferences.d/kernel

	config_message="configure distro done."
fi

## excution message
[ -z `command -v zenity` ] && echo "$config_message" || zenity --info --width=400 --text="$config_message"

## remove sources.list
rm -f /etc/apt/sources.list /etc/apt/sources.list.save
