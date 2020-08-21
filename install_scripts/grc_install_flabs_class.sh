#!/bin/bash
# Best practice is to create an install directory off your home, then 
# cloning the git repo as follows:
# cd
# mkdir install
# cd install
# git clone https://github.com/paulgclark/grc-install
# 
# NOTE: You should run one of the gnuradio installation scripts BEFORE
# you run this one. Recommended is grc_from_source.sh
#
# You should then run this script in place with the following commands:
# cd grc-install/install-scripts
# sudo ./grc_install_flabs_class.sh
# 
# If you run this script from another directory, you will break some
# relative path links and the install will fail.

# get current path and script name
SCRIPT_PATH=$PWD
SCRIPT_NAME=${0##*/}

# you should be root, if you are not, quit
if [[ $EUID != 0 ]]; then
        echo "You are attempting to run the script as user."
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

# get username
username=$SUDO_USER
# number of cores to use for make
CORES=`nproc`
# get general functions from the common file
source ./common/common_functions.sh

VERSION_38="master"
VERSION_37="maint-3.7"
REPO_URL="https://github.com/paulgclark/gr-reveng"

# select the version of the code based on which gnuradio is installed
if [ "$GRC_38" = true ]; then
        GIT_REF="$VERSION_38"
else
        GIT_REF="$VERSION_37"
fi


# install custom blocks
sudo apt -y install cmake
sudo apt -y install swig

# get and build the code for gr-rds
cd $SDR_SRC_DIR
clone_and_build $REPO_URL $GIT_REF


# installing Python code for use in some exercises
cd "$SDR_SRC_DIR" # the class-specific Python code goes to same place
sudo -u "$username" git clone https://github.com/paulgclark/rf_utilities
sudo -u "$username" echo "" >> ~/.bashrc
sudo -u "$username" echo "################################" >> ~/.bashrc
sudo -u "$username" echo "# Custom code for gnuradio class" >> ~/.bashrc
sudo -u "$username" echo "export PYTHONPATH=\$PYTHONPATH:$SDR_SRC_DIR/rf_utilities"  >> ~/.bashrc
sudo -u "$username" echo "" >> ~/.bashrc

# other useful stuff
sudo apt install -y vim
#sudo snap install pycharm-community --classic

