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

# first get a few common functions:
source ./common/common_functions.sh

# call function to get globals: script_path, script_name, user_name, cores
get_basic_info

# check if running script as root, else exit
exit_unless_root

# check that the necessary environment vars in place, else exit
check_env_vars

VERSION_38="master"
VERSION_37="maint-3.7"
repo_url="https://github.com/paulgclark/gr-reveng"

# select the version of the code based on which gnuradio is installed
if [ "$GRC_38" = true ]; then
        repo_ref="$VERSION_38"
else
        repo_ref="$VERSION_37"
fi

# install custom blocks
sudo apt -y install cmake
sudo apt -y install swig

# get and build the code for gr-reveng
cd $SDR_SRC_DIR
clone_and_build $repo_url $repo_ref


# installing Python code for use in some exercises into the same src dir
cd $SDR_SRC_DIR 
sudo -u "$username" git clone https://github.com/paulgclark/rf_utilities
sudo -u "$username" echo "" >> ~/.bashrc
sudo -u "$username" echo "################################" >> ~/.bashrc
sudo -u "$username" echo "# Custom code for gnuradio class" >> ~/.bashrc
sudo -u "$username" echo "export PYTHONPATH=\$PYTHONPATH:$SDR_SRC_DIR/rf_utilities"  >> ~/.bashrc
sudo -u "$username" echo "" >> ~/.bashrc

# install pycharm for classes 2-4
sudo snap install pycharm-community --classic

# other useful stuff
sudo apt install -y vim

