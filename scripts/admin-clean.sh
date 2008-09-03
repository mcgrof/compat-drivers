#!/bin/bash
if [ -d net ] ; then
	make clean
fi
rm -rf net drivers include Module.symvers git-describe
echo "Cleaned wireless-compat-2.6"
