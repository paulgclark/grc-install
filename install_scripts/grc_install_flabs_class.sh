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

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
cd ~/install
INSTALL_PATH=`pwd`
SRC_PATH=$INSTALL_PATH/src
TARGET_PATH=$INSTALL_PATH/sdr
cd $SCRIPT_PATH

# get username
username=$SUDO_USER

# source the environment setup script created in the gnuradio install
sudo -u "$username" source $TARGET_PATH/setup_env.sh

# install custom blocks
sudo apt -y install cmake
sudo apt -y install swig
sudo -u "$username" cd "$SRC_PATH" # custom block code lives at same level as gnuradio src
# run git clone as user so we don't have root owned files in the system
sudo -u "$username" git clone https://github.com/paulgclark/gr-reveng
sudo -u "$username" cd gr-reveng
sudo -u "$username" mkdir build
sudo -u "$username" cd build
sudo -u "$username" cmake ../ 
sudo -u "$username" make
sudo make install
sudo ldconfig

# installing Python code for use in some exercises
sudo -u "$username" cd "$SRC_PATH" # the class-specific Python code goes to same place
sudo -u "$username" git clone https://github.com/paulgclark/rf_utilities
sudo -u "$username" echo "" >> ~/.bashrc
sudo -u "$username" echo "################################" >> ~/.bashrc
sudo -u "$username" echo "# Custom code for gnuradio class" >> ~/.bashrc
sudo -u "$username" echo "export PYTHONPATH=$PYTHONPATH:"SRC_PATH"/rf_utilities"  >> ~/.bashrc
sudo -u "$username" echo "" >> ~/.bashrc

# other useful stuff
sudo apt install -y vim
sudo snap install pycharm-community --classic

# run gnuradio-companion with FM radio loaded for test
sudo -u "$username" cd "$SCRIPT_PATH"
sudo -u "$username" gnuradio-companion ../grc/uhd-test/fm_receiver_hardware_uhd_uk.grc
