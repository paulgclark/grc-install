#!/bin/bash
# This script installs gr-gsm from source. It is intended for
# execution AFTER the grc_from_source.sh script has been run and will
# install to the same target directory used for that process.
#
# This script depends on environment variables that were created during
# the gnuradio installation process, so the script must be run WITHOUT
# sudo:
# ./gsm_from_source

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

# the user must have already run the hackrf/osmosdr install
if [ ! -f $SDR_TARGET_DIR/lib/libhackrf.a ]; then
	echo "ERROR: osmosdr libraries not installed. Please run this first:"
	echo "       ./hackrf_from_source.sh"
	exit 1
fi


# number of cores to use for make
CORES=`nproc`

GSM_VERSION_38="995572b14fac0204329361509bf6ab1712af35c0" # latest release
GSM_VERSION_37="fa184a9447a90aefde2ca0dea1347b702551015d" # latest release

# get a know working version or commit
if [ "$GRC_38" = true ]; then
	GR_GSM_REPO="https://github.com/bkerler/gr-gsm"
	GR_GSM_REF=$GSM_VERSION_38
else
	GR_GSM_REPO="https://github.com/osmocom/gr-gsm"
	GR_GSM_REF="$GSM_VERSION_37"
fi

# now get and build the code for gr-osmosdr
cd $SDR_SRC_DIR
git clone --recursive $GR_GSM_REPO

# get code from a known good version
cd gr-gsm
git checkout $GR_GSM_REF
git submodule update

# fix an issue with the inclusion of -lvolk
sed -i 's/volk/ /' lib/CMakeLists.txt

# build it
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$SDR_TARGET_DIR ../
make -j$CORES
make install

