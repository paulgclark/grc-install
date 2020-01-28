#!/bin/bash
# This script installs qspectrumanalyzer from source. It does not install 
# globally, but in a local directory, similar to how PyBOMBS operates. You 
# must first run the gnuradio installation:
# grc-install/install_scripts/qspectrum_from_source.sh
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

# These are the versions that will be installed for 3.7 and 3.8
# If you want to install a different version, change these variables
QSPEC_VERSION="v2.2.0"

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD

# get username
username=$SUDO_USER

# number of cores to use for make
CORES=`nproc`


# you should be running as root; if you are not, quit
if [[ $EUID == 0 ]]; then
        echo "You are attempting to run the script with root privileges."
        echo "Please run without sudo:"
        echo "  ./qspectumanalyzer_from_source.sh"
        exit 1
fi

# there should also be an environment variable for the target and source paths
# if there is not, quit
if [[ -z "$SDR_TARGET_DIR" ]]; then
        echo "ERROR: \$SDR_TARGET_DIR not defined."
        echo "       You should run ./grc_from_source.sh before running this script."
        echo "       If you've already done that, you may need to open a new terminal"
        echo "       and try this script again. Also, make sure you run with -E:"
	echo "       sudo -E ./qspectrum_from_source.sh"
        exit 1
fi

if [[ -z "$SDR_SRC_DIR" ]]; then
        echo "ERROR: \$SDR_SRC_DIR not defined."
        echo "       You should run ./grc_from_source.sh before running this script."
        echo "       If you've already done that, you may need to open a new terminal"
        echo "       and try this script again. Also, make sure you run with -E:"
	echo "       sudo -E ./qspectrum_from_source.sh"
        exit 1
fi

# install dependencies
sudo apt update
sudo apt -y upgrade
sudo apt -y install libqt5opengl5-dev libqt5svg5-dev qt5-default
sudo apt -y install python3-pip python3-pyqt5 python3-numpy python3-scipy
sudo apt -y install python3-soapysdr
sudo apt -y install soapysdr-module-hackrf soapysdr-module-lms7

##############################
# get the repo
##############################
# get the repo
cd $SDR_SRC_DIR
git clone --recursive https://github.com/xmikos/qspectrumanalyzer

# checkout the more recent stable release
cd $SDR_SRC_DIR/qspectrumanalyzer
git checkout $QSPEC_VERSION
git submodule update

# can't install to a prefix, so installing to user directory, which 
# defaults to ~/.local
pip3 install --user .

# now update the environment at startup to point to these locations
SETUP_FILE=~/.local/qs_setup_env.sh
touch $SETUP_FILE
echo -e "# This file provides the setup information for qspectrumanalyzer" >> $SETUP_FILE
echo -e "export PATH=$PATH:~/.local/bin" >> $SETUP_FILE
echo -e "export PYTHONPATH=$PYTHONPATH:~/.local/lib/python3.6/site-packages" >> $SETUP_FILE


# add this environment setup script to bashrc unless it's already in there
if grep -q "$SETUP_FILE" ~/.bashrc; then
        :
else
	echo -e "" >> ~/.bashrc
	echo -e "########## points to a local install of qspectrumanalyzer" >> ~/.bashrc 
	echo -e "source $SETUP_FILE" >> ~/.bashrc 
fi

