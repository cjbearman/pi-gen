#!/bin/bash

echo "This script will set up raspbian images that:"
echo "1. Enable SSH by default, with your SSH authorized_keys installed"
echo "2. Have a custom login"
echo "3. Have WIFI provisioned for your network"
echo "4. Enable multicast DNS to make devices easy to find"
echo ""

rm -f config
AUTH_KEYS=$HOME/.ssh/authorized_keys
if [ -f $HOME/.ssh/authorized_keys ]; then
	while true; do
    		read -p "Do you wish to install $AUTH_KEYS? " yn
    		case $yn in
			[Yy]* ) echo "INSTALL_SSH_AUTHORIZED_KEYS=$AUTH_KEYS" >> config; break;;
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
echo "FIRST_USER_NAME=${FIRST_USER_NAME}" >> config

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
echo "FIRST_USER_PASS=${FIRST_USER_PASS}" >> config

read -p "Enter SSID of wifi network, leave empty for no wifi config: " WIFI_NET
if [ ! -z $WIFI_NET ]; then
	echo "WPA_ESSID=${WIFI_NET}" >> config
	while [ -z "$WPA_PASSWORD" ]; do
		read -s -p "Please enter wifi password: " WPA_PASSWORD
		echo ""
	done
	echo "WPA_COUNTRY=US" >> config
else 
	echo "Wifi will not be enabled"
fi

while [ -z $IMG_NAME ]; do
	read -p "Image name: " IMG_NAME
done
echo "IMG_NAME=${IMG_NAME}" >> config

while true; do
	read -p "Do you wish to build all images (yes) or just lite (no): " yn
	case $yn in
		[Yy]* ) echo "BUILD_ALL=1" >> config; break;;
		[Nn]* ) echo "BUILD_ALL=0" >> config; break;;
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

echo "ENABLE_SSH=1" >> config
echo "CLEAN=1" >> config

sudo apt-get install -y coreutils quilt parted qemu-user-static debootstrap zerofree pxz zip dosfstools bsdtar libcap2-bin grep rsync xz-utils file git curl
#./build-docker.sh
./build.sh
