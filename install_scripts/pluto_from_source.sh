#!/bin/bash
# This script installs the adalm-pluto tools from source. It is intended for
# execution AFTER the grc_from_source.sh script has been run and will
# install to the same target directory used for that process.
#
# This script depends on environment variables that were created during
# the gnuradio installation process, so the script must be run WITHOUT
# sudo:
# ./pluto_from_source

# common function code
source ./common/common_functions.sh

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
SCRIPT_NAME=${0##*/}
cd ../udev-rules
UDEV_RULES_PATH=$PWD

# you should be running as root; if you are not, quit
if [[ $EUID != 0 ]]; then
        echo "You are attempting to run the script without root privileges."
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

# number of cores to use for make
CORES=`nproc`

LIBIIO_REPO="https://github.com/analogdevicesinc/libiio"
LIB9361_REPO="https://github.com/analogdevicesinc/libad9361-iio"
GR_IIO_REPO="https://github.com/analogdevicesinc/gr-iio"
LIBIIO_REF="master"
LIB9361_REF="master"

if [ "$GRC_38" = true ]; then
	GR_IIO_REF="upgrade-3.8"
else
	GR_IIO_REF="master"
fi

# dependencies
sudo apt -y install libxml2
sudo apt -y install libxml2-dev # need this
sudo apt -y install libaio-dev # need this
sudo apt -y install libboost-all-dev
sudo apt -y install bison
sudo apt -y install flex
sudo apt -y install swig

# build (or rebuild) libiio
cd $SDR_SRC_DIR
clone_and_build $LIBIIO_REPO $LIBIIO_REF sudo "-DINSTALL_UDEV_RULE=OFF"

# build (or rebuild) libiio
cd $SDR_SRC_DIR
clone_and_build $LIB9361_REPO $LIB9361_REF

# build (or rebuild) libiio
cd $SDR_SRC_DIR
clone_and_build $GR_IIO_REPO $GR_IIO_REF


# copy hackrf rules file unless it's already there
if [ ! -f /etc/udev/rules.d/53-adi-plutosdr-usb.rules ]; then
	sudo cp $UDEV_RULES_PATH/53-adi-plutosdr-usb.rules /etc/udev/rules.d/
	sudo udevadm control --reload-rules
fi

