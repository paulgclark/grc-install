#!/bin/bash
# This script installs gr-satellites from source. It is intended for
# execution AFTER the grc_from_source.sh script has been run and will
# install to the same target directory used for that process.
#
# This script depends on environment variables that were created during
# the gnuradio installation process, so the script must be run WITHOUT
# sudo:
# ./satellites_from_source.sh

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
SCRIPT_NAME=${0##*/}

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
	echo "       You should run ./$SCRIPT_NAME before running this script."
	echo "       If you've already done that, you may need to open a new terminal"
	echo "       and try this script again."
	exit 1
fi

if [[ -z "$SDR_SRC_DIR" ]]; then
        echo "ERROR: \$SDR_SRC_DIR not defined."
	echo "       You should run ./$SCRIPT_NAME before running this script."
	echo "       If you've already done that, you may need to open a new terminal"
	echo "       and try this script again."
	exit 1
fi

# install prereqs
sudo apt -y install liborc-0.4-dev
sudo apt -y install feh

# number of cores to use for make
CORES=`nproc`

VERSION_39="v4.2.0" # latest release
VERSION_38="v3.9.0" # latest release
VERSION_37="v3.7.0" # latest release

# get a known working version or commit
if [ "$GRC_38" = true ]; then
	pip3 install --user --upgrade construct requests
	GIT_REF=$VERSION_38
else
	pip install --user --upgrade construct requests
	GIT_REF="$VERSION_37"
fi

# get code from a known good version
cd $SDR_SRC_DIR
git clone https://github.com/daniestevez/gr-satellites
cd gr-satellites
git checkout $GIT_REF
git submodule update

# build it
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$SDR_TARGET_DIR ../
make -j$CORES
make install

