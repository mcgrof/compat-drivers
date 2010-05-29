#!/bin/bash
MODULES="bluetooth btusb l2cap sco hidp rfcomm bnep"
for i in $MODULES; do
	echo Loading $i...
	modprobe $i
done
echo Starting bluetooth service..
/etc/init.d/bluetooth start
/etc/init.d/bluetooth status

