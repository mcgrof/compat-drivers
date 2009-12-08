#!/bin/bash
MODULES="bluetooth btusb l2cap sco hidp rfcomm bnep"
for i in $MODULES; do
	echo Loading $i...
	modprobe $i
done
echo Starting bluetooth service..
sudo service bluetooth start
sudo service bluetooth status

