#!/bin/bash
# This script installs the hackrf tools from source. It is intended for
# execution AFTER the grc_from_source.sh script has been run and will
# install to the same target directory used for that process.
#
# This script depends on environment variables that were created during
# the gnuradio installation process, so the script must be run WITHOUT
# sudo:
# ./hackrf_from_source

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
cd ../udev-rules
UDEV_RULES_PATH=$PWD

# you should not be root, if you are, quit
if [[ $EUID == 0 ]]; then
	echo "You are attempting to run the script as root."
	echo "Please do not run with sudo, but simply run:"
	echo "  ./hackrf_from_source"
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

HACKRF_VERSION="v2018.01.1" # latest release

if [ "$GRC_38" = true ]; then
	GR_OSMOSDR_VERSION="v0.1.5"
else
	GR_OSMOSDR_VERSION="v0.1.4"
fi

# get the repo and put it with the source from the grc install step
cd $SDR_SRC_DIR
git clone --recursive https://github.com/mossmann/hackrf.git

# get code from a known good version
cd $SDR_SRC_DIR/hackrf
git checkout $HACKRF_VERSION
git submodule update

# build it
cd host
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$SDR_TARGET_DIR -DINSTALL_UDEV_RULES=Off ../
make -j$CORES
make install


# now get and build the code for gr-osmosdr
cd $SDR_SRC_DIR
git clone --recursive https://github.com/osmocom/gr-osmosdr

# get code from a known good version
cd $SDR_SRC_DIR/gr-osmosdr
git checkout $GR_OSMOSDR_VERSION
git submodule update

# build it
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$SDR_TARGET_DIR ../
make -j$CORES
make install


# copy hackrf rules file unless it's already there
if [ ! -f /etc/udev/rules.d/53-hackrf.rules ]; then
	sudo cp $UDEV_RULES_PATH/53-hackrf.rules /etc/udev/rules.d/
	sudo udevadm control --reload-rules
fi

