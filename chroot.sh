#! /bin/bash

# author: Rushied Q. Alwusaby
# email: rush@wusaby.me

if [ "$#" -eq 0 ]; then
  optionsArray=( --help )
else
  optionsArray=( "$@" )
fi

# check if
if [[ " ${optionsArray[*]} " =~ " --help " ]]; then
    echo "usage like: chroot.sh --help"
    echo "usage like: chroot.sh /dev/sda1"
    echo "usage like: chroot.sh /dev/sda1 --net"
    exit
fi

DIR=/xxx
DISK=$1

umount $DISK;
mkdir $DIR;
mount $DISK $DIR;

if [[ " ${optionsArray[*]} " =~ " --net " ]]; then
    mount -t proc proc $DIR/proc
    mount -t sysfs sys $DIR/sys
    mount -o bind /dev $DIR/dev
    mount -t devpts pts $DIR/dev/pts/
    mount -o bind /run $DIR/run
    cp /etc/resolv.conf $DIR/etc/resolv.conf
fi

chroot $DIR /bin/bash
rmdir $DIR
