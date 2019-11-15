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

# get username
username=$SUDO_USER

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
cd ~/install
INSTALL_PATH=`pwd`
SRC_PATH=$INSTALL_PATH/src
TARGET_PATH=$INSTALL_PATH/sdr
cd $SCRIPT_PATH

# execute the environment setup script created in the gnuradio install
sudo -u "$username" bash $TARGET_PATH/setup_env.sh

# install custom blocks
sudo apt -y install cmake
sudo apt -y install swig
cd "$SRC_PATH" # custom block code lives at same level as gnuradio src
# run git clone as user so we don't have root owned files in the system
sudo -u "$username" git clone https://github.com/paulgclark/gr-reveng
cd gr-reveng
sudo -u "$username" mkdir build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH ../ 
sudo -u "$username" make
sudo -u "$username" make install

# installing Python code for use in some exercises
cd "$SRC_PATH" # the class-specific Python code goes to same place
sudo -u "$username" git clone https://github.com/paulgclark/rf_utilities
sudo -u "$username" echo "" >> ~/.bashrc
sudo -u "$username" echo "################################" >> ~/.bashrc
sudo -u "$username" echo "# Custom code for gnuradio class" >> ~/.bashrc
sudo -u "$username" echo "export PYTHONPATH=\$PYTHONPATH:$SRC_PATH/rf_utilities"  >> ~/.bashrc
sudo -u "$username" echo "" >> ~/.bashrc

# other useful stuff
sudo apt install -y vim
sudo snap install pycharm-community --classic

