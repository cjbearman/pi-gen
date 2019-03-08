#!/bin/bash

echo "This script will set up raspbian images that:"
echo "1. Enable SSH by default, with your SSH authorized_keys installed"
echo "2. Have a custom login"
echo "3. Have WIFI provisioned for your network"
echo "4. Enable multicast DNS to make devices easy to find"
echo ""

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root (sudo ./run.sh)"
	exit 1
fi


AUTH_KEYS=$HOME/.ssh/authorized_keys
if [ -f $HOME/.ssh/authorized_keys ]; then
	while true; do
    		read -p "Do you wish to install $AUTH_KEYS? " yn
    		case $yn in
			[Yy]* ) export INSTALL_SSH_AUTHORIZED_KEYS=$AUTH_KEYS; break;;
        		[Nn]* ) echo "Okay, will not install $AUTH_KEYS"; break;;
        		* ) echo "Please answer yes or no.";;
    		esac
	done
else
	echo "Did not find $AUTH_KEYS, so will not install them"
fi

while [ -z "$FIRST_USER_NAME" ]; do
	read -p "Please enter name of login user: " FIRST_USER_NAME
done
export FIRST_USER_NAME

while [ -z "$FIRST_USER_PASS" ]; do
	read -s -p "Please enter password of login user   : " FIRST_USER_PASS
	echo ""
	read -s -p "Please confirm password of login user : " FIRST_USER_PASS_CONF
	echo ""

	if [ "$FIRST_USER_PASS" != "$FIRST_USER_PASS_CONF" ]; then
		FIRST_USER_PASS=""
		echo "Passwords do not match, please try again"
	fi
done
export FIRST_USER_PASS

read -p "Enter SSID of wifi network, leave empty for no wifi config: " WIFI_NET
if [ ! -z $WIFI_NET ]; then
	export WPA_ESSID=$WIFI_NET
	while [ -z "$WPA_PASSWORD" ]; do
		read -s -p "Please enter wifi password: " WPA_PASSWORD
		echo ""
	done
	export WPA_PASSWORD
	export WPA_COUNTRY=US
else 
	echo "Wifi will not be enabled"
fi

while [ -z $IMG_NAME ]; do
	read -p "Image name: " IMG_NAME
done
export IMG_NAME

while true; do
	read -p "Do you wish to build all images (yes) or just lite (no): " yn
	case $yn in
		[Yy]* ) BUILD_ALL=1; break;;
		[Nn]* ) BUILD_ALL=0; break;;
		* ) echo "Please answer yes or no.";;
	esac
done

rm -f stage?/SKIP stage?/SKIP_IMAGES
if [ "$BUILD_ALL" = "0" ]; then
	touch ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP
	touch ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES
	echo "Building lite images only"
else
	echo "Building all images"
fi

export ENABLE_SSH=1
export CLEAN=1

apt-get install -y coreutils quilt parted qemu-user-static debootstrap zerofree pxz zip dosfstools bsdtar libcap2-bin grep rsync xz-utils file git curl
./build.sh
