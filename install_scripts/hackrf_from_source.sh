#!/bin/bash
# This script installs the hackrf tools from source. It is intended for
# execution AFTER the grc_from_source.sh script has been run and will
# install to the same target directory used for that process.
#

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
cd ../udev-rules
UDEV_RULES_PATH=$PWD

# get username
username=$SUDO_USER

# number of cores to use for make
CORES=`nproc`

HACKRF_VERSION="v2018.01.1" # latest release
GR_OSMOSDR_VERSION="v0.1.4"

# get the repo and put it with the source from the grc install step
cd $SDR_SRC_DIR
sudo -u "$username" git clone --recursive https://github.com/mossmann/hackrf.git

# get code from a known good version
cd $SDR_SRC_DIR/hackrf
sudo -u "$username" git checkout $HACKRF_VERSION
sudo -u "$username" git submodule update

# build it
cd host
sudo -u "$username" mkdir build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$SDR_TARGET_DIR -DINSTALL_UDEV_RULES=Off ../
sudo -u "$username" make -j$CORES
sudo -u "$username" make install


# now get and build the code for gr-osmosdr
cd $SDR_SRC_DIR
sudo -u "$username" git clone --recursive https://github.com/osmocom/gr-osmosdr

# get code from a known good version
cd $SDR_SRC_DIR/gr-osmosdr
sudo -u "$username" git checkout $GR_OSMOSDR_VERSION
sudo -u "$username" git submodule update

# build it
sudo -u "$username" mkdir build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$SDR_TARGET_DIR ../
sudo -u "$username" make -j$CORES
sudo -u "$username" make install


# copy hackrf rules file
sudo cp $UDEV_RULES_PATH/53-hackrf.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules

