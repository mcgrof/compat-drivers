#!/usr/bin/env bash
# Copyright 2009-2012  Luis R. Rodriguez <mcgrof@do-not-panic.com>
#
# You can use this to make compat-drivers releases:
#
#   * daily linux-next.git based compat-drivers releases
#   * linux-stable.git / linux.git stable releases
#
# The assumption is you have the linux-stable git tree on your $HOME
#
# git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
# git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
#
# You can add linux.git on to your linux-stable.git as a remote to get
# Linus's RC's and you should add linux-stable.git as a local remote
# to your linux-next.git so you can get then get the linux-stable tags
# for your linux-next.git tree.
#
# By default we refer to the GIT_TREE variable for where we are pulling
# code for a release and guestimate what type of release you want
# from that. By default we assume you want a daily linux-next.git tree
# release.

# Pretty colors
GREEN="\033[01;32m"
YELLOW="\033[01;33m"
NORMAL="\033[00m"
BLUE="\033[34m"
RED="\033[31m"
PURPLE="\033[35m"
CYAN="\033[36m"
UNDERLINE="\033[02m"

GIT_STABLE_URL="git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git"
GIT_NEXT_URL="git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git"

STABLE_TREE="linux-stable"
NEXT_TREE="linux-next"

STAGING=/tmp/staging/compat-drivers/

function usage()
{
	echo -e "Usage:"
	echo -e ""
	echo -e "export GIT_TREE=${HOME}/linux-stable/"
	echo -e "or"
	echo -e "export GIT_TREE=${HOME}/linux-next/"
	echo -e ""
	echo -e "${GREEN}$1${NORMAL} ${BLUE}[ -s | -n | -p | -c ]${NORMAL}"
	echo
	echo Examples usages:
	echo
	echo -e "export GIT_TREE=${HOME}/linux-stable/"
	echo -e "${PURPLE}${1} -s -n -p -c${NORMAL}"
	echo or
	echo -e "export GIT_TREE=${HOME}/linux-next/"
	echo -e "${PURPLE}${1} -p -c${NORMAL}"
	echo
	exit
}

UPDATE_ARGS=""
POSTFIX_RELEASE_TAG="-"

if [ -z $GIT_TREE ]; then
	export GIT_TREE=$HOME/$NEXT_TREE
	if [ ! -d $GIT_TREE ]; then
		echo "Please tell me where your linux-next or linux-stable git tree is."
		echo "You can do this by exporting its location as follows:"
		echo
		echo "  export GIT_TREE=${HOME}/linux-next/"
		echo "or"
		echo "  export GIT_TREE=${HOME}/linux-stable/"
		echo
		echo "If you do not have one you can clone the repositories at:"
		echo "  git clone $GIT_STABLE_URL"
		echo "  git clone $GIT_NEXT_URL"
		exit 1
	fi
else
	echo "You said to use git tree at: $GIT_TREE"
fi

COMPAT_DRIVERS_DIR=$(pwd)
COMPAT_DRIVERS_BRANCH=$(git branch | grep \* | awk '{print $2}')

cd $GIT_TREE
# --abbrev=0 on branch should work but I guess it doesn't on some releases
EXISTING_BRANCH=$(git branch | grep \* | awk '{print $2}')

# target branch we want to use from hpa's tree, by default
# this respects the existing branch on the target kernel.
# You can override the target branch by specifying an argument
# to this script.
TARGET_BRANCH="$EXISTING_BRANCH"

while [ $# -ne 0 ]; do
	if [[ "$1" = "-s" ]]; then
		UPDATE_ARGS="${UPDATE_ARGS} $1"
		POSTFIX_RELEASE_TAG="${POSTFIX_RELEASE_TAG}s"
		shift; continue;
	fi
	if [[ "$1" = "-n" ]]; then
		UPDATE_ARGS="${UPDATE_ARGS} $1"
		POSTFIX_RELEASE_TAG="${POSTFIX_RELEASE_TAG}n"
		shift; continue;
	fi
	if [[ "$1" = "-p" ]]; then
		UPDATE_ARGS="${UPDATE_ARGS} $1"
		POSTFIX_RELEASE_TAG="${POSTFIX_RELEASE_TAG}p"
		shift; continue;
	fi
	if [[ "$1" = "-c" ]]; then
		UPDATE_ARGS="${UPDATE_ARGS} $1"
		POSTFIX_RELEASE_TAG="${POSTFIX_RELEASE_TAG}c"
		shift; continue;
	fi

	echo -e "Unexpected argument passed: ${RED}${1}${NORMAL}"
	usage $0
	exit
done

BASE_TREE=$(basename $GIT_TREE)

echo "On ${BASE_TREE}: $TARGET_BRANCH"

# Lets now make sure you are on matching compat-drivers branch.
# This is a super hack, but let me know if you figure out a cleaner way
TARGET_KERNEL_RELEASE=$(make VERSION="linux-3" SUBLEVEL="" EXTRAVERSION=".y" kernelversion)

if [[ $COMPAT_DRIVERS_BRANCH != $TARGET_KERNEL_RELEASE && $BASE_TREE != "linux-next" ]]; then
	echo -e "You are on the compat-drivers ${GREEN}${COMPAT_DRIVERS_BRANCH}${NORMAL} but are "
	echo -en "on the ${RED}${TARGET_KERNEL_RELEASE}${NORMAL} branch... "
	echo -e "try changing to that first."

	read -p "Do you still want to continue (y/N)? "
	if [[ "${REPLY}" != "y" ]]; then
	    echo -e "Bailing out !"
	    exit
	fi
fi

cd $COMPAT_DRIVERS_DIR

if [[ $COMPAT_DRIVERS_BRANCH != "master" ]]; then
	RELEASE=$(git describe --abbrev=0 | sed -e 's/v//g')
else
	RELEASE=$(git describe --abbrev=0)
fi

if [[ $POSTFIX_RELEASE_TAG != "-" ]]; then
	RELEASE="${RELEASE}${POSTFIX_RELEASE_TAG}"
fi
RELEASE_TAR="$RELEASE.tar.bz2"

rm -rf $STAGING
mkdir -p $STAGING
cp -a $COMPAT_DRIVERS_DIR $STAGING/$RELEASE
cd $STAGING/$RELEASE

./scripts/admin-update.sh $UPDATE_ARGS
rm -rf $STAGING/$RELEASE/.git

# Remove any gunk
echo
echo "Cleaning up the release ..."
make clean 2>&1 > /dev/null
find ./ -type f -name *.orig | xargs rm -f
find ./ -type f -name *.rej  | xargs rm -f

cd $STAGING/

echo "Creating ${RELEASE}.tar ..."
tar -cf ${RELEASE}.tar $RELEASE/
bzip2 -9 ${RELEASE}.tar

# kup allows us to upload a compressed archive but wants us
# to sign the tarball alone, it will uncompress the
# compressed tarball, verify the tarball and then re-compress
# the tarball.
gpg --armor --detach-sign ${RELEASE}.tar

# XXX: Add this for daily / stable release:
# kup put ${RELEASE}.tar.bz2 ${RELEASE}.tar.asc /pub/linux/kernel/projects/backports/2012/09/18/

echo
echo "compat-drivers release: $RELEASE"
echo "Size: $(du -h ${RELEASE_TAR})"
echo "sha1sum: $(sha1sum ${RELEASE_TAR})"
echo
echo "Release:           ${STAGING}${RELEASE_TAR}"
echo "Release signature: ${STAGING}${RELEASE}.tar.asc"
