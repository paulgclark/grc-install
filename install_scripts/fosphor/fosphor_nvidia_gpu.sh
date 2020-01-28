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

# install dependencies
sudo apt -y install cmake xorg-dev libglu1-mesa-dev swig3.0 qt4-default qtcreator python-qt4 swig wget
#sudo apt -y install mesa-opencl-icd

# install glfw
cd "$SRC_PATH" # custom block code lives at same level as gnuradio src
# run git clone as user so we don't have root owned files in the system
sudo -u "$username" git clone https://github.com/glfw/glfw
cd glfw
sudo -u "$username" mkdir build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH -DBUILD_SHARED_LIBS=true ../ 
sudo -u "$username" make
sudo -u "$username" make install

# final installation
sudo apt -y install nvidia-opencl-dev
sudo apt -y install opencl-headers
sudo apt -y install clinfo

# now install gr-fosphor itself
cd "$SRC_PATH" # custom block code lives at same level as gnuradio src
sudo -u "$username" git clone git://git.osmocom.org/gr-fosphor

# need to use sed/awk to modify the following file:
# gr-fosphor/grc/fosphor_qt_sink_c.xml
# $(gui_hint()($win))</make>  BECOMES $(gui_hint() % $win)</make>
sed -i '/gui_hint()/ s/(\$win)/ % \$win/' gr-fosphor/grc/fosphor_qt_sink_c.xml
# gr-fosphor/lib/fosphor/private.h
# #define FLG_FOSPHOR_USE_CLGL_SHARING    (1<<0)  BECOMES  #define FLG_FOSPHOR_USE_CLGL_SHARING    (0<<0)
sed -i '/FLG_FOSPHOR_USE_CLGL_SHARING/ s/1<<0/0<<0/' gr-fosphor/lib/fosphor/private.h

cd gr-fosphor
sudo -u "$username" mkdir build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH ../
sudo -u "$username" make
sudo -u "$username" make install
 
