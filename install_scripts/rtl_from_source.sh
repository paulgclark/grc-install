#!/bin/bash
# This script installs the rtl-sdr tools from source. It is intended for
# execution AFTER the grc_from_source.sh script has been run and will
# install to the same target directory used for that process.
#
# This script depends on environment variables that were created during
# the gnuradio installation process, so the script must be run WITHOUT
# sudo:
# ./rtl_from_source

# first get a common function
source ./common/common_functions.sh

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
SCRIPT_NAME=${0##*/}
cd ../udev-rules
UDEV_RULES_PATH=$PWD
set -x
# you should not be root, if you are, quit
if [[ $EUID == 0 ]]; then
	echo "You are attempting to run the script as root."
	echo "Please do not run with sudo, but simply run:"
	echo "  ./$SCRIPT_NAME"
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

# number of cores to use for make
CORES=`nproc`

REPO_URL="https://github.com/osmocom/rtl-sdr"

# get a know working version or commit
if [ "$GRC_38" = true ]; then
	GIT_REF="" #
	echo "rtl-sder not yet supported by these scripts on gnuradio 3.8"
	exit 1
else
	GIT_REF="0.6.0"
fi


# get and build the code for gr-rds
cd $SDR_SRC_DIR
clone_and_build $REPO_URL $GIT_REF user "-DDETACH_KERNEL_DRIVER=ON"

# copy hackrf rules file unless it's already there
if [ ! -f /etc/udev/rules.d/20-rtlsdr.rules ]; then
	sudo cp $UDEV_RULES_PATH/20-rtlsdr.rules /etc/udev/rules.d/
	sudo udevadm control --reload-rules
fi

