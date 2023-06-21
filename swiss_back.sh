#!/bin/bash

# Author: Rushied Qaied Alwusbay
# Email: rush@wusaby.me
# Version: 0.08
# Script use to Create a clone of your apllications and data

################## CLI

flaty_cli () {
	# choose process
	PS3='Choose a process for Flaty:'
	select CHOICE in suck place cancel
	do
	break
	done
	
	# process choices
	case $CHOICE in
	
		"suck")
			read -p "enter a path for flaty file (where you want to extract): " DIR
			cd ~/.local/share
			tar -czvf "$DIR"/Flaty$(date +"%d%m%y%H%S")@$USER.tar.gz flatpak
			;;

		"place")
			read -p "enter the path of flaty file: " FROM
			rm -rf ~/.local/share/flatpak && tar -xzvf "$FROM" -C ~/.local/share
			;;

		"*")
			exit 0
			;;
	esac	
}

apps_cli () {
	# choose process
	PS3='Choose a process for Apps data:'
	select CHOICE in suck place cancel
	do
	break
	done
	
	# process choices
	case $CHOICE in
	
		"suck")
			read -p "enter a path for apps file (where you want to extract): " DIR
			cd ~/.var
			tar -czvf "$DIR"/Apps$(date +"%d%m%y%H%S")@$USER.tar.gz app
			;;

		"place")
			read -p "enter the path of apps file: " FROM
			rm -rf ~/.var/app && tar -xzvf "$FROM" -C ~/.var
			;;

		"*")
			exit 0
			;;
	esac	
}

boxes_cli () {
	# choose process
	PS3='Choose a process for Boxes data:'
	select CHOICE in suck place cancel
	do
	break
	done
	
	# process choices
	case $CHOICE in
	
		"suck")
			read -p "enter a path for boxes file (where you want to extract): " DIR
			cd ~/.var
			tar -czvf "$DIR"/Boxes$(date +"%d%m%y%H%S")@$USER.tar.gz box
			;;

		"place")
			read -p "enter the path of boxes file: " FROM
			rm -rf ~/.var/box && tar -xzvf "$FROM" -C ~/.var
			;;

		"*")
			exit 0
			;;
	esac	
}

# TODO: need redefine
pods_cli () {
	# choose process
	PS3='Choose a process for Boxes:'
	select CHOICE in suck place cancel
	do
	break
	done
	
	# process choices
	case $CHOICE in
	
		"suck")
			read -p "enter a path for boxes files (where you want to extract): " DIR
			cd ~/.local/share
			tar -czvf "$DIR"/Pods$(date +"%d%m%y%H%S")@$USER.tar.gz containers
			;;

		"place")
			read -p "enter the path of pods file: " FROM
			rm -rf ~/.local/share/containers && tar -xzvf "$FROM" -C ~/.local/share
			;;

		"*")
			exit 0
			;;
	esac	
}

swiss_back_cli () {
	# check of privilages
	if [[ $EUID == 0 ]]; then
		# TODO: print to std err
		echo "This script must not run as root"
		exit 2
	fi
	
	# main
	flaty_cli
	apps_cli
	boxes_cli
	pods_cli
}

################## GUI

flaty_gui () {
	# choose process
	CHOICE=$(zenity --list --radiolist --column Selection --column Process --column Choice --print-column=3 --hide-column=3 --text="Choose a process for Flaty" FALSE "suck" 1 TRUE "place" 2 FALSE "cancel" 3)

	# process choices
	case $CHOICE in

		"1")
			DIR=$(zenity  --file-selection --title="Choose a directory" --directory) || return 1
			cd ~/.local/share
			# TODO: add real progress for zenity and tar command
		    tar -czvf "$DIR"/Flaty$(date +"%d%m%y%H%S")@$USER.tar.gz flatpak | zenity --progress --auto-close
			[ `echo $?` == 0 ] && zenity --info --text="Suck Flaty complete." || zenity --error --text="An error has ocurred, check space."
			;;

		"2")
			FROM=$(zenity --file-selection --title="select Flaty file" --filename "${HOME}/" --file-filter="Flaty*.tar.gz") || return 1
			rm -rf ~/.local/share/flatpak && tar -xzvf "$FROM" -C ~/.local/share | zenity --progress --auto-close
			[ `echo $?` == 0 ] && zenity --info --text="Place Flaty complete." || zenity --error --text="An error has ocurred, check space."
			;;

		"*")
			exit 0
			;;
	esac	
}

apps_gui () {
	# choose process
	CHOICE=$(zenity --list --radiolist --column Selection --column Process --column Choice --print-column=3 --hide-column=3 --text="Choose a process for Apps data" FALSE "suck" 1 TRUE "place" 2 FALSE "cancel" 3)

	# process choices
	case $CHOICE in

		"1")
			DIR=$(zenity  --file-selection --title="Choose a directory" --directory) || return 1
			[ -z $DIR ] && exit 1
			cd ~/.var
			# TODO: add real progress for zenity and tar command
		    tar -czvf "$DIR"/Apps$(date +"%d%m%y%H%S")@$USER.tar.gz app | zenity --progress --auto-close
			[ `echo $?` == 0 ] && zenity --info --text="Suck Apps complete." || zenity --error --text="An error has ocurred, check space."
			;;

		"2")
			FROM=$(zenity --file-selection --title="select Apps file" --filename "${HOME}/" --file-filter="Apps*.tar.gz") || return 1
			rm -rf ~/.var/app && tar -xzvf "$FROM" -C ~/.var | zenity --progress --auto-close
			[ `echo $?` == 0 ] && zenity --info --text="Place Apps complete." || zenity --error --text="An error has ocurred, check space."
			;;

		"*")
			exit 0
			;;
	esac	
}

boxes_gui () {
	# choose process
	CHOICE=$(zenity --list --radiolist --column Selection --column Process --column Choice --print-column=3 --hide-column=3 --text="Choose a process for Boxes data" FALSE "suck" 1 TRUE "place" 2 FALSE "cancel" 3)

	# process choices
	case $CHOICE in

		"1")
			DIR=$(zenity  --file-selection --title="Choose a directory" --directory) || return 1
			[ -z $DIR ] && exit 1
			cd ~/.var
			# TODO: add real progress for zenity and tar command
		    tar -czvf "$DIR"/Boxes$(date +"%d%m%y%H%S")@$USER.tar.gz box | zenity --progress --auto-close
			[ `echo $?` == 0 ] && zenity --info --text="Suck Boxes complete." || zenity --error --text="An error has ocurred, check space."
			;;

		"2")
			FROM=$(zenity --file-selection --title="select Boxes file" --filename "${HOME}/" --file-filter="Boxes*.tar.gz") || return 1
			rm -rf ~/.var/box && tar -xzvf "$FROM" -C ~/.var | zenity --progress --auto-close
			[ `echo $?` == 0 ] && zenity --info --text="Place Boxes complete." || zenity --error --text="An error has ocurred, check space."
			;;

		"*")
			exit 0
			;;
	esac	
}

pods_gui () {
	# choose process
	CHOICE=$(zenity --list --radiolist --column Selection --column Process --column Choice --print-column=3 --hide-column=3 --text="Choose a process for Pods" FALSE "suck" 1 TRUE "place" 2 FALSE "cancel" 3)

	# process choices
	case $CHOICE in

		"1")
			DIR=$(zenity  --file-selection --title="Choose a directory" --directory) || return 1
			cd ~/.local/share
			# TODO: add real progress for zenity and tar command
		    tar -czvf "$DIR"/Pods$(date +"%d%m%y%H%S")@$USER.tar.gz containers | zenity --progress --auto-close
			[ `echo $?` == 0 ] && zenity --info --text="Suck Pods complete." || zenity --error --text="An error has ocurred, check space."
			;;

		"2")
			FROM=$(zenity --file-selection --title="select Pods file" --filename "${HOME}/" --file-filter="Pods*.tar.gz") || return 1
			rm -rf ~/.local/share/containers && tar -xzvf "$FROM" -C ~/.local/share | zenity --progress --auto-close
			[ `echo $?` == 0 ] && zenity --info --text="Place Pods complete." || zenity --error --text="An error has ocurred, check space."
			;;

		"*")
			exit 0
			;;
	esac	
}

swiss_back_gui () {
	# check of privilages
	if [[ $EUID == 0 ]]; then
		zenity --error --width=400 --text="This script must not run as root"
		exit 2
	fi
	
	# main
	flaty_gui
	apps_gui
	boxes_gui
	pods_gui
}

################## MAIN

if [ -z `command -v zenity` ]; then
	swiss_back_cli
else
    swiss_back_gui
fi


multi_select (){
# TODO: fix output, convert to array
options=( $(distrobox list | tail -n +2 | awk '{print $3}') )

menu() {
    echo "Avaliable options:"
    for i in ${!options[@]}; do 
	printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${options[i]}"
    done
    if [[ "$msg" ]]; then echo "$msg"; fi
}

prompt="Check an option (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
    [[ "$num" != *[![:digit:]]* ]] &&
    (( num > 0 && num <= ${#options[@]} )) ||
    { msg="Invalid option: $num"; continue; }
    ((num--)); msg="${options[num]} was ${choices[num]:+un}checked"
    [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
done

printf "You selected"; msg=" nothing"
for i in ${!options[@]}; do 
    [[ "${choices[i]}" ]] && { printf " %s" "${options[i]}"; msg=""; }
done
echo "$msg"
}