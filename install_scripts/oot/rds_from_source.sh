#!/bin/bash
# This script installs the RDS OOT modules from source. It is intended for
# execution AFTER the grc_from_source.sh script has been run and will
# install to the same target directory used for that process.
#
# This script depends on environment variables that were created during
# the gnuradio installation process, so the script must be run WITHOUT
# sudo:
# ./rds_from_source
#
# Thanks to Dr. Bloessel for creating and releasing this code!

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
SCRIPT_NAME=${0##*/}

# you should be root, if you are not, quit
if [[ $EUID != 0 ]]; then
	echo "You are attempting to run the script as user."
	echo "Please run with sudo:"
	echo "  sudo -E ./$SCRIPT_NAME"
	exit 1
fi

# there should also be an environment variable for the target and source paths
# if there is not, quit
if [[ -z "$SDR_TARGET_DIR" ]]; then
        echo "ERROR: \$SDR_TARGET_DIR not defined."
	echo "       You should run ./grc_from_source.sh before running this script."
	echo "       If you've already done that, you may need to open a new terminal"
	echo "       and try this script again."
	exit 1
fi

if [[ -z "$SDR_SRC_DIR" ]]; then
        echo "ERROR: \$SDR_SRC_DIR not defined."
	echo "       You should run ./grc_from_source.sh before running this script."
	echo "       If you've already done that, you may need to open a new terminal"
	echo "       and try this script again."
	exit 1
fi

# get username
username=$SUDO_USER
# number of cores to use for make
CORES=`nproc`
# get general functions from the common file
source ../common/common_functions.sh

# these are the versions of the code known to work for 3.7 and 3.8
VERSION_38="v3.8.0"
VERSION_37="v1.1.0"

REPO_URL="https://github.com/bastibl/gr-rds"

# select the version of the code based on which gnuradio is installed
if [ "$GRC_38" = true ]; then
	GIT_REF="$VERSION_38"
else
	GIT_REF="$VERSION_37"
fi

# install wireshark, unless its already installed
sudo apt update
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' wireshark |grep "install ok installed")
if [ "" == "$PKG_OK" ]; then
  	echo "No wireshark installed, doing so now."
	sudo apt -y install wireshark
	sudo groupadd wireshark
	sudo usermod -a -G wireshark $username
	sudo chgrp wireshark /usr/bin/dumpcap
	sudo chmod 750 /usr/bin/dumpcap
	sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
	sudo getcap /usr/bin/dumpcap
else
	echo "Wireshark already installed. Skipping installation."
	echo "Note, if you previously installed this yourself, please"
	echo "ensure that you have set up your groups and permissions"
        echo "appropriately."
fi

# get and build the code for gr-rds
cd $SDR_SRC_DIR
clone_and_build $REPO_URL $GIT_REF

