#!/bin/bash
if [ -d net ] ; then
	make clean
fi
rm -rf net drivers include
rm -rf drivers
rm -rf include
rm -f Module.symvers
rm -f git-describe
rm -f master-tag
rm -f compat-git-release
rm -f compat-release
echo "Cleaned wireless-bt-compat-2.6"
