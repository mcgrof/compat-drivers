#!/bin/bash
MODULES="ipw2100 ipw2200 libertas_cs usb8xxx"
MODULES="$MODULES p54pci p54usb"
MODULES="$MODULES adm8211 zd1211rw"
MODULES="$MODULES rtl8180 rtl8187"
MODULES="$MODULES p54pci p54usb"
MODULES="$MODULES iwl3945 iwlagn"
MODULES="$MODULES ath ar9170usb"
MODULES="$MODULES rtl8180 rtl8187"
MODULES="$MODULES rt2400pci rt2500pci rt61pci"
MODULES="$MODULES rt2500usb rt73usb"
MODULES="$MODULES rndis_wlan at76_usb"
MODULES="$MODULES mwl8k mac80211_hwsim"
MODULES="$MODULES at76c50x_usb"
MODULES="$MODULES bluetooth btusb l2cap sco hidp rfcomm bnep"
for i in $MODULES; do
	echo Loading $i...
	modprobe $i
done
# For ath5k we must be sure to unload MadWifi first
athload ath5k
# For b43 we must make sure to unload bcm43xx first
b43load b43
echo Starting bluetooth service..
/etc/init.d/bluetooth start
/etc/init.d/bluetooth status
