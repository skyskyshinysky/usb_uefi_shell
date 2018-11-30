#!/usr/bin/env bash

set -e

ME=`basename $0`

ROOT=$(pwd)
BOOT_DIR_TMP="$ROOT/temp/EFI/BOOT"
MOUNTED_DIR="/mnt/usb"
BOOT_DIR=$MOUNTED_DIR/boot
GRUB_DIR=$BOOT_DIR/grub

SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

fail()
{
	$SETCOLOR_FAILURE
	echo -n "$(tput hpa $(tput cols))$(tput cub 6)[fail]"
	$SETCOLOR_NORMAL
	echo
	exit 0
}

success()
{
	$SETCOLOR_SUCCESS
	echo -n "$(tput hpa $(tput cols))$(tput cub 6)[OK]"
	$SETCOLOR_NORMAL
	echo
}

help()
{

	echo "Usage: ./$ME <path to UefiShell.efi> <path to device>"
	echo "Download the UEFI Shell (Shell.efi) from the following link"
	echo "https://github.com/tianocore/edk2/raw/master/ShellBinPkg/UefiShell/X64/Shell.efi"

	exit 0
}

prepare_usb_device()
{
	echo "Preparing usb device..."
	path_to_device=$1
	name_part="${path_to_device}1"
	dd if=/dev/zero of=$path_to_device  bs=512  count=1
	sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<- EOF | fdisk $path_to_device
	n
	p
	1


	a
	t
	c
	w
	EOF
	sleep 5
	mkfs.fat -F 32 -v -I -n UsbShell $name_part
	mkdir -pv $MOUNTED_DIR && mount $name_part $MOUNTED_DIR
}

install_usb()
{
	path_to_device=$1
		
	echo "Copying on usb..."
	cp -a $ROOT/temp/* $MOUNTED_DIR
	sleep 5
}

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root"
	exit 1
fi

if [ $# = 0 ] || [ $# != 2 ]; then
	help
else
	path_to_uefi_shell=$1
	path_to_device=$2
	name_part="${path_to_device}1"

	if [ $(mount | grep -c $path_to_device) != 0 ]; then
		echo -n "Please, unmount the device"
		echo 
		exit
	fi
	echo "Preparation..."
	rm -rf temp

	echo "Creating temp directory..."
	mkdir -pv $ROOT/temp/EFI/BOOT
	echo "Copy uefi shell image..."
	cp $path_to_uefi_shell $BOOT_DIR_TMP/Bootx64.efi

	if [ ! -f $BOOT_DIR_TMP/Bootx64.efi ]; then
		echo "File $BOOT_DIR_TMP/Bootx64.efi not found!"
		echo "Copying kernel failed!"
		fail
	else
		success
		prepare_usb_device $path_to_device
		success
		install_usb $path_to_device
		success
		sleep 5
		
		echo "Unmounting device..."
		umount --lazy $name_part
		$SETCOLOR_NORMAL
		echo "Remove temp directory..."
		rm -rf temp
		$SETCOLOR_NORMAL
		echo ""
	fi																																													
fi
