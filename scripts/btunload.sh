#!/bin/bash
MODULES="hidp rfcomm bnep l2cap sco btusb bluetooth"
echo Stoping bluetooth service..
sudo service bluetooth stop
sudo service bluetooth status

for i in $MODULES; do
	grep ^$i /proc/modules 2>&1 > /dev/null
	if [ $? -eq 0 ]; then
		echo Unloading $i...
		modprobe -r --ignore-remove $i
	fi
done
