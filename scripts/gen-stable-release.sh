#!/bin/bash
# Copyright 2009  Luis R. Rodriguez <mcgrof@gmail.com>
#
# You can use this to make stable compat-wireless releases
#
# The assumption is you have the linux-2.6-allstable git tree on your $HOME
# git://git.kernel.org/pub/scm/linux/kernel/git/hpa/linux-2.6-allstable.git
#
# Local branches will be created based on the remote linux-2.6.X.y branches.
# If your branch already exists we will nuke it for you to avoid rebasing.
#
# If no kernel is specified we use the latest rc-release, which will be on the
# remove master branch. Your master branch should be clean.

ALL_STABLE_TREE="linux-2.6-allstable"
STAGING=/tmp/staging/compat-wireless/

if [[ $# -gt 1 ]]; then
	echo "Usage: $0 <linux-2.6.X.y>"
	echo
	echo Examples usages:
	echo
	echo  $0
	echo  $0 linux-2.6.29.y
	echo  $0 linux-2.6.30.y
	echo
	echo "If no kernel is specified we try to make a release based on the latest RC kernel."
	echo "If a kernel release is specified X is the next stable release as 31 in 2.6.31.y."
	exit
fi

# branch we want to use from hpa's tree
BRANCH="$1"

export GIT_TREE=$HOME/$ALL_STABLE_TREE
COMPAT_WIRELESS_DIR=$(pwd)

cd $GIT_TREE
# --abbrev=0 on branch should work but I guess it doesn't on some releases
LOCAL_BRANCH=$(git branch | grep \* | awk '{print $2}')

case $LOCAL_BRANCH in
"master") # Preparing a new stable compat-wireless release based on an RC kernel
	git checkout -f
	git pull
	# Rebase will be done automatically if our tree is clean
	echo "On master branch on $ALL_STABLE_TREE"
	;;
*) # Based on a stable 2.6.x.y release, lets just move to the master branch,
   # git pull, nuke the old branch and start a fresh new branch.
	echo "On non-master branch on $ALL_STABLE_TREE: $LOCAL_BRANCH"
	git checkout -f
	git checkout master
	git pull
	git branch -D $LOCAL_BRANCH
	git checkout -b $LOCAL_BRANCH origin/$LOCAL_BRANCH
	;;
esac

# We should now be on the branch we want
KERNEL_RELEASE=$(git describe --abbrev=0 | sed -e 's/v//g')
RELEASE="compat-wireless-$KERNEL_RELEASE"
RELEASE_TAR="$RELEASE.tar.bz2"

rm -rf $STAGING
mkdir -p $STAGING
cp -a $COMPAT_WIRELESS_DIR $STAGING/$RELEASE
cd $STAGING/$RELEASE

./scripts/admin-update.sh
rm -rf $STAGING/$RELEASE/.git

# Remove any gunk
echo
echo "Cleaning up the release ..."
make clean 2>&1 > /dev/null
find ./ -type f -name *.orig | xargs rm -f
find ./ -type f -name *.rej  | xargs rm -f

cd $STAGING/

echo "Creating $RELEASE_TAR ..."
tar -jcf $RELEASE_TAR $RELEASE/

echo
echo "Compat-wireles release: $RELEASE"
echo "Size: $(du -h $RELEASE_TAR)"
echo "sha1sum: $(sha1sum $RELEASE_TAR)"
echo
echo "Release: ${STAGING}$RELEASE_TAR"
