#!/bin/bash

# Author: Rushied Qaied Alwusbay
# Email: rush@wusaby.com
# Version: 0.02
# Script use to Create a clone of flatpak or write clone to system

# TODO: print error message to stdrr, and use one message in two commands
if [ -z `command -v flatpak` ]; then
	[ -z `command -v zenity` ] && echo $'flatpak is not installed \nto install it visit https://flatpak.org/setup/' || zenity --error --width=400 --text="flatpak is not installed \nto install it visit https://flatpak.org/setup/"
	exit 1
fi

# check of root privilages
if [[ $EUID -e 0 ]]; then
	root_message="This script must not run as root"
	[ -z `command -v zenity` ] && echo "$root_message" || zenity --error --width=400 --text="$root_message"
	exit 2
fi


# TODO: use select rather than `read -p`
# TODO: orgnize choice code in functions to back them after any process or as alias
CHOICE=$(zenity --list --radiolist --column Selection --column Process --column Choice --print-column=3 --hide-column=3 --text="Which process you need" FALSE "Configure repos [need net]" 0 TRUE "Suck Flaty" 1 FALSE "Place Flaty" 2) || read -p $'Which proccess you need:\n0) Configure repos [need net]\n1) Suck Flaty\n2) Place Flaty\npress any key to exit\n' CHOICE

# process choices
case $CHOICE in

	"0")
		flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && zenity --info --text="Add flathub repo done." || zenity --error --text="An error has ocurred, check network."
		;;

	"1")
		DIR=~
		TO=$DIR/Flaty$(date +"%d%m%y%H%S")@$USER.tar.gz
		cd ~/.local/share
		#tar -czvf $TO flatpak
        [ -z `command -v zenity` ] && tar -czvf $TO flatpak || tar -czvf $TO flatpak | zenity --progress --auto-close
		[ `echo $?` == 0 ] && zenity --info --text="Suck Flaty complete." || zenity --error --text="An error has ocurred, check space."
		;;

	"2")
		# TODO: remove this snippet
        #check of root privilages
		#if [[ $EUID -ne 0 ]]; then
		#	echo "This script must be run as root"
		#	exit 2
		#fi
		FROM=$(zenity --file-selection --title="select Flaty file" --filename "${HOME}/" --file-filter="*.tar.gz") || read -p "enter the path of flaty file: " FROM
		rm -rf ~/.local/share/flatpak && \
		# TODO: add real progress for zenity and tar command
		[ -z `command -v zenity` ] && tar -xzvf "$FROM" -C ~/.local/share || tar -xzvf "$FROM" -C ~/.local/share | zenity --progress --auto-close
		[ `echo $?` == 0 ] && zenity --info --text="Place Flaty complete."; exit 0
		zenity --error --text="An error has ocurred, check space."
		;;

	"*")
		exit 0
		;;
esac
