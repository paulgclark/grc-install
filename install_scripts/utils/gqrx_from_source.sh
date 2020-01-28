#!/bin/bash
# This script installs gqrx from source. It does not install globally, 
# but in a local directory, similar to how PyBOMBS operates. You must
# first run the gnuradio installation:
# grc-install/install_scripts/grc_from_source.sh
#
# If you plan to run with a HackRF, you should also install this before
# running the qgrx install:
# grc-install/install_scripts/hackrf_from_source.sh
#
# Finally, you should then open a new window and run this script in 
# place with the following commands:
# cd grc-install/install-scripts/utils
# sudo ./gqrx_from_source.sh
#
set -xv
# These are the versions that will be installed for 3.7 and 3.8
# If you want to install a different version, change these variables
GQRX_VERSION="v2.11.5"

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD

# get username
username=$SUDO_USER

# number of cores to use for make
CORES=`nproc`


# you should be running as root; if you are not, quit
if [[ $EUID != 0 ]]; then
        echo "You are attempting to run the script root without root privileges."
        echo "Please run with sudo:"
        echo "  sudo ./grc_from_source.sh"
        exit 1
fi

# there should also be an environment variable for the target and source paths
# if there is not, quit
if [[ -z "$SDR_TARGET_DIR" ]]; then
        echo "ERROR: \$SDR_TARGET_DIR not defined."
        echo "       You should run ./grc_from_source.sh before running this script."
        echo "       If you've already done that, you may need to open a new terminal"
        echo "       and try this script again. Also, make sure you run with -E:"
	echo "       sudo -E ./gqrx_from_source.sh"
        exit 1
fi

if [[ -z "$SDR_SRC_DIR" ]]; then
        echo "ERROR: \$SDR_SRC_DIR not defined."
        echo "       You should run ./grc_from_source.sh before running this script."
        echo "       If you've already done that, you may need to open a new terminal"
        echo "       and try this script again. Also, make sure you run with -E:"
	echo "       sudo -E ./gqrx_from_source.sh"
        exit 1
fi

# install dependencies
sudo apt update
sudo apt -y upgrade
sudo apt -y install libqt5opengl5-dev libqt5svg5-dev qt5-default


##############################
# get the repo
cd $SDR_SRC_DIR
sudo -u "$username" git clone --recursive https://github.com/csete/gqrx

# checkout the more recent stable release
cd $SDR_SRC_DIR/gqrx
sudo -u "$username" git checkout $GQRX_VERSION
sudo -u "$username" git submodule update

# build UHD
sudo -u "$username" mkdir -p build
cd build
# assign the PREFIX value with the call to qmake
sudo -Eu "$username" qmake PREFIX=$SDR_TARGET_DIR ../
sudo -Eu "$username" bash -c \
	                "export LD_LIBRARY_PATH=$SDR_TARGET_DIR/lib; \
	                 export LD_LOAD_LIBRARY=$SDR_TARGET_DIR/lib; \
			 make -j$CORES"
sudo -Eu "$username" make install

