#!/bin/bash
# 
# Copyright 2007, 2008	Luis R. Rodriguez <mcgrof@winlab.rutgers.edu>
#
# Use this to update compat-wireless-2.6 to the latest
# wireless-testing.git tree you have.
#
# Usage: you should have the latest pull of wireless-2.6.git
# git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-testing.git
# We assume you have it on your ~/devel/wireless-testing/ directory. If you do,
# just run this script from the compat-wireless-2.6 directory.
# You can specify where your GIT_TREE is by doing:
#
# export GIT_TREE=/home/mcgrof/wireless-testing/
# 
# for example
#
GIT_URL="git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-testing.git"

INCLUDE_LINUX="ieee80211.h nl80211.h wireless.h"
INCLUDE_LINUX="$INCLUDE_LINUX pci_ids.h bitops.h eeprom_93cx6.h pm_qos_params.h"
INCLUDE_LINUX="$INCLUDE_LINUX ath9k_platform.h"

# For rndis_wext
INCLUDE_LINUX_USB="usbnet.h rndis_host.h"

INCLUDE_LINUX_SPI="wl12xx.h libertas_spi.h"

# The good new yummy stuff
INCLUDE_NET="cfg80211.h ieee80211_radiotap.h"
INCLUDE_NET="$INCLUDE_NET mac80211.h wext.h lib80211.h regulatory.h"

# Pretty colors
GREEN="\033[01;32m"
YELLOW="\033[01;33m"
NORMAL="\033[00m"
BLUE="\033[34m"
RED="\033[31m"
PURPLE="\033[35m"
CYAN="\033[36m"
UNDERLINE="\033[02m"

NET_DIRS="wireless mac80211 rfkill"
# User exported this variable
if [ -z $GIT_TREE ]; then
	GIT_TREE="/home/$USER/devel/wireless-testing/"
	if [ ! -d $GIT_TREE ]; then
		echo "Please tell me where your wireless-testing git tree is."
		echo "You can do this by exporting its location as follows:"
		echo
		echo "  export GIT_TREE=/home/$USER/wireless-testing/"
		echo
		echo "If you do not have one you can clone the repository:"
		echo "  git-clone $GIT_URL"
		exit 1
	fi
else
	echo "You said to use git tree at: $GIT_TREE"
fi
# Drivers that have their own directory
DRIVERS="drivers/net/wireless/ath"
DRIVERS="$DRIVERS drivers/net/wireless/ath/ar9170"
DRIVERS="$DRIVERS drivers/net/wireless/ath/ath5k"
DRIVERS="$DRIVERS drivers/net/wireless/ath/ath9k"
DRIVERS="$DRIVERS drivers/ssb"
DRIVERS="$DRIVERS drivers/net/wireless/b43"
DRIVERS="$DRIVERS drivers/net/wireless/b43legacy"
DRIVERS="$DRIVERS drivers/net/wireless/iwlwifi"
DRIVERS="$DRIVERS drivers/net/wireless/rt2x00"
DRIVERS="$DRIVERS drivers/net/wireless/zd1211rw"
DRIVERS="$DRIVERS drivers/net/wireless/libertas"
DRIVERS="$DRIVERS drivers/net/wireless/p54"
DRIVERS="$DRIVERS drivers/net/wireless/rtl818x"
DRIVERS="$DRIVERS drivers/net/wireless/libertas_tf"
DRIVERS="$DRIVERS drivers/net/wireless/ipw2x00"
DRIVERS="$DRIVERS drivers/net/wireless/wl12xx"
DRIVERS="$DRIVERS drivers/net/wireless/iwmc3200wifi"

# Drivers that belong the the wireless directory
DRIVER_FILES="adm8211.c  adm8211.h"
DRIVER_FILES="$DRIVER_FILES rndis_wlan.c"
DRIVER_FILES="$DRIVER_FILES mac80211_hwsim.c"
DRIVER_FILES="$DRIVER_FILES at76c50x-usb.c at76c50x-usb.h"
DRIVER_FILES="$DRIVER_FILES mwl8k.c"

mkdir -p include/linux/ include/net/ include/linux/usb \
	include/linux/unaligned \
	include/linux/spi \
	net/mac80211/ net/wireless/ \
	net/rfkill/ \
	drivers/ssb/ \
	drivers/net/usb/ \
	drivers/net/wireless/

# include/linux
DIR="include/linux"
for i in $INCLUDE_LINUX; do
	echo "Copying $GIT_TREE/$DIR/$i"
	cp "$GIT_TREE/$DIR/$i" $DIR/
done

cp -a $GIT_TREE/include/linux/ssb include/linux/
cp -a $GIT_TREE/include/linux/rfkill.h include/linux/rfkill_backport.h

# include/net
DIR="include/net"
for i in $INCLUDE_NET; do
	echo "Copying $GIT_TREE/$DIR/$i"
	cp "$GIT_TREE/$DIR/$i" $DIR/
done

DIR="include/linux/usb"
for i in $INCLUDE_LINUX_USB; do
	echo "Copying $GIT_TREE/$DIR/$i"
	cp $GIT_TREE/$DIR/$i $DIR/
done

DIR="include/linux/spi"
for i in $INCLUDE_LINUX_SPI; do
	echo "Copying $GIT_TREE/$DIR/$i"
	cp $GIT_TREE/$DIR/$i $DIR/
done

# net/wireless and net/mac80211
for i in $NET_DIRS; do
	echo "Copying $GIT_TREE/net/$i/*.[ch]"
	cp $GIT_TREE/net/$i/*.[ch] net/$i/
	cp $GIT_TREE/net/$i/Makefile net/$i/
	rm -f net/$i/*.mod.c
done

# Drivers in their own directory
for i in $DRIVERS; do
	mkdir -p $i
	echo "Copying $GIT_TREE/$i/*.[ch]"
	cp $GIT_TREE/$i/*.[ch] $i/
	cp $GIT_TREE/$i/Makefile $i/
	rm -f $i/*.mod.c
done

# For rndis_wlan, we need a new rndis_host.ko, cdc_ether.ko and usbnet.ko
RNDIS_REQS="Makefile rndis_host.c cdc_ether.c usbnet.c"
DIR="drivers/net/usb"
for i in $RNDIS_REQS; do
	echo "Copying $GIT_TREE/$DIR/$i"
	cp $GIT_TREE/$DIR/$i $DIR/
done

# b44 is dependent on ssb, so its has to be rebuilt as well.
DIR="drivers/net"
cp $GIT_TREE/$DIR/b44.[ch] $DIR
echo "obj-\$(CONFIG_B44) += b44.o" > $DIR/Makefile

# Misc
mkdir -p drivers/misc/eeprom/
cp $GIT_TREE/drivers/misc/eeprom/eeprom_93cx6.c drivers/misc/eeprom/
cp $GIT_TREE/drivers/misc/eeprom/Makefile drivers/misc/eeprom/

DIR="drivers/net/wireless"
# Drivers part of the wireless directory
for i in $DRIVER_FILES; do
	cp $GIT_TREE/$DIR/$i $DIR/
done

# Top level wireless driver Makefile
cp $GIT_TREE/$DIR/Makefile $DIR

DIR="include/linux/unaligned"
echo "Copying $GIT_TREE/$DIR/*"
cp $GIT_TREE/$DIR/* $DIR


# Compat stuff
cp compat/compat-2.6.*.c net/wireless/
cp compat/compat-2.6.*.h include/net/
cp compat/compat.h include/net/

for i in compat/patches/*.patch; do
	echo -e "${GREEN}Applying backport patch${NORMAL}: ${BLUE}$i${NORMAL}"
	patch -p1 -N -t < $i
	RET=$?
	if [[ $RET -ne 0 ]]; then
		echo -e "${RED}Patching $i failed${NORMAL}, update it"
		exit $RET
	fi
done

DIR="$PWD"
cd $GIT_TREE
GIT_DESCRIBE=$(git describe)
echo -e "${GREEN}Updated${NORMAL} from local tree: ${BLUE}${GIT_TREE}${NORMAL}"
echo -e "Origin remote URL: ${CYAN}$(git config remote.origin.url)${NORMAL}"
cd $DIR
if [ -d ./.git ]; then

	cd $GIT_TREE
	TREE_NAME=$(git config remote.origin.url)
	TREE_NAME=${TREE_NAME##*/}

	echo $TREE_NAME > $DIR/git-describe
	echo $GIT_DESCRIBE >> $DIR/git-describe

	echo -e "git-describe for $TREE_NAME says: ${PURPLE}$GIT_DESCRIBE${NORMAL}"

	rm -f $DIR/master-tag
	case $TREE_NAME in
	"wireless-testing.git") # John's wireless-testing
		cd $DIR
		git tag -l | grep "master" | tail -1 > compat-release
		cd $GIT_TREE
		MASTER_TAG=$(git tag -l| grep master | tail -1)
		echo $MASTER_TAG > $DIR/master-tag
		echo -e "This is a ${RED}bleeding edge${NORMAL} compat-wireless release based on: ${PURPLE}$MASTER_TAG${NORMAL}"
		;;
	"linux-2.6-allstable.git") # HPA's all stable tree
		cd $DIR
		git tag -l | grep "2.6" | tail -1 > compat-release
		cd $GIT_TREE
		echo -e "This is a ${GREEN}stable${NORMAL} compat-wireless release based on: ${PURPLE}$(git describe --abbrev=0)${NORMAL}"
		;;
	"linux-2.6.git") # Linus' 2.6 tree
		cd $DIR
		git tag -l | grep "2.6" > compat-release
		cd $GIT_TREE
		;;
	*)
		;;
	esac

	cd $DIR
fi

./scripts/driver-select restore

echo -e "This is compat-release: ${YELLOW}$(cat compat-release)${NORMAL}"
