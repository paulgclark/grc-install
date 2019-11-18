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

# installing OpenCL for Intel CPU; modify these steps if you intend to use 
# AMD or GPU

# install gmmlib (???? Aren't we getting this from the binaries?)
cd "$SRC_PATH" # custom block code lives at same level as gnuradio src
# run git clone as user so we don't have root owned files in the system
sudo -u "$username" git clone https://github.com/intel/gmmlib
cd gmmlib
sudo -u "$username" mkdir build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH -DCMAKE_BUILD_TYPE=Release -DARCH=64 ../
sudo -u "$username" make
sudo -u "$username" make install

# install the five intel_deb packages (downloadable?)
cd "$SRC_PATH" # custom block code lives at same level as gnuradio src
sudo -u "$username" mkdir opencl_binaries
cd opencl_binaries
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/19.44.14658/intel-gmmlib_19.3.2_amd64.deb
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/19.44.14658/intel-igc-core_1.0.2714.1_amd64.deb
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/19.44.14658/intel-igc-opencl_1.0.2714.1_amd64.deb
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/19.44.14658/intel-opencl_19.44.14658_amd64.deb
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/19.44.14658/intel-ocloc_19.44.14658_amd64.deb
sudo dpkg -i *.deb

# final installation
sudo apt -y install ocl-icd-opencl-dev

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
 
