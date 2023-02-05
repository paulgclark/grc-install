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


# get a know working version or commit
if [ "$GRC_310" = true ]; then
	GR_OSMOSDR_REPO="https://github.com/osmocom/gr-osmosdr"
	GR_OSMOSDR_REF="v0.2.4"
	HACKRF_VERSION="v2023.01.1" # latest release
elif [ "$GRC_38" = true ]; then
	# there is currently no version of gr-osmosdr from
	# the original authors that works with gnuradio 3.8
	GR_OSMOSDR_REPO="https://github.com/igorauad/gr-osmosdr"
	# this specific commit has been tested and works
	GR_OSMOSDR_REF="f3905d3510dfb3851f946f097a9e2ddaa5fb333b"
	HACKRF_VERSION="v2018.01.1" # latest release
else
	GR_OSMOSDR_REPO="https://github.com/osmocom/gr-osmosdr"
	GR_OSMOSDR_REF="v0.1.4"
	HACKRF_VERSION="v2018.01.1" # latest release
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
cmake -DCMAKE_INSTALL_PREFIX=$SDR_TARGET_DIR -DINSTALL_UDEV_RULES=OFF ../
make -j$CORES
make install


# now get and build the code for gr-osmosdr
cd $SDR_SRC_DIR
git clone --recursive $GR_OSMOSDR_REPO

# get code from a known good version
cd gr-osmosdr
git checkout $GR_OSMOSDR_REF
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

