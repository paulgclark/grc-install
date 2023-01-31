#!/bin/bash
# This script installs 3 OOT modules from source. It is intended for
# execution AFTER the grc_from_source.sh script has been run and will
# install to the same target directory used for that process.
#
# This script depends on environment variables that were created during
# the gnuradio installation process, so the script must be run with the
# -E option for sudo:
# sudo -E ./bastibl_from_source.sh
#
# Thanks to Dr. Bloessel for creating and releasing this code!

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD

# you should be root, if you are not, quit
if [[ $EUID != 0 ]]; then
	echo "You are attempting to run the script as user."
	echo "Please run with sudo:"
	echo "  sudo -E ./bastibl_from_source.sh"
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

BASTIBL_VERSION_310="maint-3.10"
BASTIBL_VERSION_38="maint-3.8"
BASTIBL_VERSION_37="maint-3.7" # replace with specific commits?

REPO_FOO="https://github.com/bastibl/gr-foo"
REPO_802_11="https://github.com/bastibl/gr-ieee802-11"
REPO_ZIGBEE="https://github.com/bastibl/gr-ieee802-15-4"

# get a know working version or commit
if [ "$GRC_38" == "true" ]; then
	GIT_REF="$BASTIBL_VERSION_38"
elif [ "$GRC_310" == "true" ]; then
	GIT_REF="$BASTIBL_VERSION_310"
else
	GIT_REF="$BASTIBL_VERSION_37"
fi

# get prereqs
sudo apt update
# wireshark first, unless its already installed
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' wireshark |grep "install ok installed")
if [ "" == "$PKG_OK" ]; then
  	echo "No wireshark installed, doing so now."
	sudo DEBIAN_FRONTEND=noninteractive apt -y install wireshark
	sudo groupadd wireshark
	sudo usermod -a -G wireshark $username
	sudo chgrp wireshark /usr/bin/dumpcap
	sudo chmod 750 /usr/bin/dumpcap
	sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
	sudo getcap /usr/bin/dumpcap
	# because we setup wireshark in silent mode, we didn't get to select 
	# "yes" in the GUI when asked if users should be able to capture
	sudo setfacl -m u:$username:x /usr/bin/dumpcap
else
	echo "Wireshark already installed. Skipping installation."
	echo "Note, if you previously installed this yourself, please"
	echo "ensure that you have set up your groups and permissions"
        echo "appropriately."
fi

# then binwalk
sudo apt -y install binwalk

# get the function from the common file
source ../common/common_functions.sh

# get and build the code for gr-foo
cd $SDR_SRC_DIR
clone_and_build $REPO_FOO $GIT_REF

# get and build the code for gr-802-11
cd $SDR_SRC_DIR
clone_and_build $REPO_802_11 $GIT_REF
sudo sysctl -w kernel.shmmax=2147483648

# get and build the code for zigbee
cd $SDR_SRC_DIR
clone_and_build $REPO_ZIGBEE $GIT_REF


# this setup file should be run before working with the 801.11 module
SETUP_FILE=$SCRIPT_PATH/bastibl_setup_env.sh
rm $SETUP_FILE
touch $SETUP_FILE
echo -e "# This file handles setup bastible modules" >> $SETUP_FILE
echo -e "sudo sysctl -w kernel.shmmax=2147483648" >> $SETUP_FILE

# add this environment setup script to bashrc unless it's already in there
# I'm adding it commented out to negate any impact to your system, please
# manually uncomment if you want to run the utilities
if grep -q "$SETUP_FILE" ~/.bashrc; then
        :
else
        echo -e "" >> ~/.bashrc
        echo -e "########## points to a local install of a bastibl setup script" >> ~/.bashrc 
        echo -e "#source $SETUP_FILE" >> ~/.bashrc 
fi

