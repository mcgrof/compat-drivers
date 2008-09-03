#!/bin/bash
MODULES="ipw2100 ipw2200 libertas_cs usb8xxx"
MODULES="$MODULES p54pci p54usb"
MODULES="$MODULES adm8211 zd1211rw"
MODULES="$MODULES rtl8180 rtl8187"
MODULES="$MODULES p54pci p54usb"
MODULES="$MODULES iwl3945 iwl4965"
MODULES="$MODULES rtl8180 rtl8187"
MODULES="$MODULES rtl8180 rtl8187"
MODULES="$MODULES rt2400pci rt2500pci rt61pci"
MODULES="$MODULES rt2500usb rt73usb"
MODULES="$MODULES rndis_wlan at76_usb"
for i in $MODULES; do
	echo Loading $i...
	modprobe $i
done
# For ath5k we must be sure to unload MadWifi first
athload ath5k
# For b43 we must make sure to unload bcm43xx first
b43load b43
