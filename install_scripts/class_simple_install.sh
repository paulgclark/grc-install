#!/bin/bash
# This script will install gnuradio 3.7.11, applying a necessary patch.
# It will also install the necessary files to get the USRP hardware
# working. Finally, the gr-reveng OOT blocks are installed.

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
# get directory into which git project was cloned
cd ../..
INSTALL_PATH=`pwd`
cd $SCRIPT_PATH

# get username
username=$SUDO_USER

# next three needed for installing custom blocks (aka OOT blocks)
sudo apt -y install git
sudo apt -y install cmake
sudo apt -y install swig

# pre-reqs
sudo apt -y install liborc-0.4-dev
sudo apt -y install feh

# install gr-reveng custom block
cd $INSTALL_PATH  
sudo -u $username mkdir -p src
# run git clone as user so we don't have root owned files in the user space
sudo -u $username git clone https://github.com/paulgclark/gr-reveng
cd gr-reveng
sudo -u $username mkdir build
cd build
sudo -u $username cmake ../
sudo -u $username make
sudo make install
sudo ldconfig

# install gr-satellites custom block
cd $INSTALL_PATH/src 
# run git clone as user so we don't have root owned files in the user space
sudo -u $username git clone https://github.com/daniestevez/gr-satellites
cd gr-satellites
sudo -u $username mkdir build
cd build
sudo -u $username cmake ../
sudo -u $username make
sudo make install
sudo ldconfig

# install pycharm
sudo snap install pycharm-community --classic

# add Python code
cd $INSTALL_PATH/src 
sudo -u $username git clone https://github.com/paulgclark/rf_utilities
# add bashrc path
sudo -u $username echo "" >> ~/.bashrc
sudo -u $username echo "################################" >> ~/.bashrc
sudo -u $username echo "# Custom code for gnuradio class" >> ~/.bashrc
sudo -u $username echo "export PYTHONPATH=\$PYTHONPATH:$INSTALL_PATH/src/rf_utilities"  >> ~/.bashrc
sudo -u $username echo "" >> ~/.bashrc

