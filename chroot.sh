#! /bin/bash

# author: Rushied Q. Alwusaby
# email: rush@wusaby.com

if [ "$#" -eq 0 ]; then
  optionsArray=( --help )
else
  optionsArray=( "$@" )
fi

# check if help is requested
if [[ " ${optionsArray[*]} " =~ " --help " ]]; then
    echo "usage like: $0 --help"
    echo "usage like: $0 /dev/sda1"
    echo "usage like: $0 /dev/sda1 --net"
    echo "usage like: $0 /path/to/directory --net"
    exit 0
fi

TARGET=$1

# 1. Detect if TARGET is a Block Device or a Directory
if [ -b "$TARGET" ]; then
    # It's a disk/partition
    ROOT=/xxx
    umount "$TARGET" 2>/dev/null # Ignore error if not mounted
    mkdir -p "$ROOT"
    mount "$TARGET" "$ROOT"
    IS_DISK=true
elif [ -d "$TARGET" ]; then
    # It's already a directory
    ROOT="$TARGET"
    IS_DISK=false
else
    echo "Error: '$TARGET' is neither a valid disk device nor a directory."
    exit 1
fi

# 2. Mount system directories if --net is requested
if [[ " ${optionsArray[*]} " =~ " --net " ]]; then
    mount -t proc proc "$ROOT/proc"

    for d in dev sys run; do
      mount --rbind "/$d" "$ROOT/$d"
      mount --make-rslave "$ROOT/$d"
    done

    # Backup resolv.conf just in case
    if [ -f "$ROOT/etc/resolv.conf" ]; then
        mv "$ROOT/etc/resolv.conf" "$ROOT/etc/resolv.conf.bak"
    fi
    
    rm -f "$ROOT/etc/resolv.conf"
    cp -L /etc/resolv.conf "$ROOT/etc/resolv.conf"
fi

# 3. Enter the chroot environment
chroot "$ROOT" /bin/bash

# 4. CLEANUP (Happens after you type 'exit' inside the chroot)
echo "Exiting chroot. Cleaning up mounts..."

if [[ " ${optionsArray[*]} " =~ " --net " ]]; then
    # Recursively unmount the bind mounts
    umount -R "$ROOT/proc"
    
    for d in run sys dev; do umount -R "$ROOT/$d"; done

    # Restore the original resolv.conf
    if [ -f "$ROOT/etc/resolv.conf.bak" ]; then
        mv "$ROOT/etc/resolv.conf.bak" "$ROOT/etc/resolv.conf"
    fi
fi

# Only unmount and delete /xxx if we originally mounted a disk
if [ "$IS_DISK" = true ]; then
    umount "$ROOT"
    rmdir "$ROOT"
fi

echo "Done."
