#!/bin/bash
# This script installs the uhd drivers and gnuradio from source. It does
# not install globally, but in a local directory, similar to how PyBOMBS
# operates. 
#
# Best practice is to create an install directory off your home, then 
# cloning this repo as follows:
# cd
# mkdir install
# cd install
# git clone https://github.com/paulgclark/grc-install
#
# You should then run this script in place with the following commands:
# cd grc-install/install-scripts
# sudo ./grc_from_source.sh
#
# Optionally, you can pass arguments for custom values for the following:
# - install path
# - target path
# - source path

# you should be running as root, if you are not, quit
if [[ $EUID != 0 ]]; then
        echo "You are attempting to run the script root without root privileges."
        echo "Please run with sudo:"
        echo "  sudo ./grc_from_source.sh"
        exit 1
fi

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD

# check if arg been passed for install path, else use ~/install
if [ "$1" != "" ]; then
	INSTALL_PATH=$1
else
	cd ~/install
	INSTALL_PATH=`pwd`
fi

# check if arg passed for target path, else use subdir of INSTALL_PATH
if [ "$2" != "" ]; then
	TARGET_PATH=$2
else
	TARGET_PATH=$INSTALL_PATH/sdr
fi

# check if arg passed for source path, else use subdir of INSTALL_PATH
if [ "$3" != "" ]; then
	SRC_PATH=$3
else
	SRC_PATH=$INSTALL_PATH/src
fi

# get username
username=$SUDO_USER

# number of cores to use for make
CORES=`nproc`

# if you want to install different versions of these, you can see a list of 
# releases on github, or by running the following command after the recursive
# clone operation:
# git tag -l
UHD_VERSION="v3.14.1.1"
GRC_VERSION="v3.7.13.5"

cd $SCRIPT_PATH

sudo apt update
sudo apt -y upgrade

sudo apt-get -y install git swig cmake doxygen build-essential libboost-all-dev libtool libusb-1.0-0 libusb-1.0-0-dev libudev-dev libncurses5-dev libfftw3-bin libfftw3-dev libfftw3-doc libcppunit-1.14-0 libcppunit-dev libcppunit-doc ncurses-bin cpufrequtils python-numpy python-numpy-doc python-numpy-dbg python-scipy python-docutils qt4-bin-dbg qt4-default qt4-doc libqt4-dev libqt4-dev-bin python-qt4 python-qt4-dbg python-qt4-dev python-qt4-doc libqwt6abi1 libncurses5 libncurses5-dbg libfontconfig1-dev libxrender-dev libpulse-dev g++ automake autoconf python-dev libusb-dev fort77 libsdl1.2-dev python-wxgtk3.0 ccache python-opengl libgsl-dev python-cheetah python-mako python-lxml qt4-dev-tools libqwtplot3d-qt5-dev pyqt4-dev-tools python-qwt5-qt4 wget libxi-dev gtk2-engines-pixbuf r-base-dev python-tk liborc-0.4-0 liborc-0.4-dev libasound2-dev python-gtk2 libzmq3-dev libzmq5 python-requests python-sphinx libcomedi-dev python-zmq libqwt-dev python-six libgps-dev libgps23 gpsd gpsd-clients python-gps python-setuptools libcanberra-gtk-module xterm

# create source and target directories
sudo -u "$username" mkdir -p $INSTALL_PATH
sudo -u "$username" mkdir -p $SRC_PATH
sudo -u "$username" mkdir -p $TARGET_PATH


############################## UHD
# get the repo
cd $SRC_PATH
sudo -u "$username" git clone --recursive https://github.com/EttusResearch/uhd

# checkout the more recent stable release
cd $SRC_PATH/uhd
sudo -u "$username" git checkout $UHD_VERSION
sudo -u "$username" git submodule update

# build UHD
cd $SRC_PATH/uhd/host
sudo -u "$username" mkdir -p build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH ../
sudo -u "$username" make -j$CORES
sudo -u "$username" make install

# copy UHD rules file
sudo cp $SRC_PATH/uhd/host/utils/uhd-usrp.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger

# resolve thread priority issue
sudo groupadd usrp
sudo usermod -aG usrp $USER
sudo sh -c "echo '@usrp\t-\trtprio\t99' >> /etc/security/limits.conf"


############################## GNURADIO
# now build gnuradio from source
cd $SRC_PATH
sudo -u "$username" git clone --recursive https://github.com/gnuradio/gnuradio

# checkout the intended release
cd $SRC_PATH/gnuradio
sudo -u "$username" git checkout $GRC_VERSION 
sudo -u "$username" git submodule update

# build gnuradio
sudo -u "$username" mkdir -p build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH -DUHD_DIR=$TARGET_PATH/lib/cmake/uhd/ -DUHD_INCLUDE_DIRS=$TARGET_PATH/include/ -DUHD_LIBRARIES=$TARGET_PATH/lib/libuhd.so ../
sudo -u "$username" make -j$CORES
sudo -u "$username" make install

# create the environment file
cd $TARGET_PATH
sudo -u "$username" touch setup_env.sh

sudo -u "$username" echo -e "LOCALPREFIX=$TARGET_PATH" >> setup_env.sh
sudo -u "$username" echo -e "export PATH=\$LOCALPREFIX/bin:\$PATH" >> setup_env.sh
sudo -u "$username" echo -e "export LD_LOAD_LIBRARY=\$LOCALPREFIX/lib:\$LD_LOAD_LIBRARY" >> setup_env.sh
sudo -u "$username" echo -e "export LD_LIBRARY_PATH=\$LOCALPREFIX/lib:\$LD_LIBRARY_PATH" >> setup_env.sh
sudo -u "$username" echo -e "export PYTHONPATH=\$LOCALPREFIX/lib/python2.7/site-packages:\$PYTHONPATH" >> setup_env.sh
sudo -u "$username" echo -e "export PYTHONPATH=\$LOCALPREFIX/lib/python2.7/dist-packages:\$PYTHONPATH" >> setup_env.sh
sudo -u "$username" echo -e "export PKG_CONFIG_PATH=\$LOCALPREFIX/lib/pkgconfig:\$PKG_CONFIG_PATH" >> setup_env.sh
sudo -u "$username" echo -e "export UHD_RFNOC_DIR=\$LOCALPREFIX/share/uhd/rfnoc/" >> setup_env.sh
sudo -u "$username" echo -e "export UHD_IMAGES_DIR=\$LOCALPREFIX/share/uhd/images" >> setup_env.sh
sudo -u "$username" echo -e "" >> setup_env.sh
sudo -u "$username" echo -e "########## for compiling software that depends on UHD" >> setup_env.sh
sudo -u "$username" echo -e "export UHD_DIR=$TARGET_PATH" >> setup_env.sh
sudo -u "$username" echo -e "export UHD_LIBRARIES=$TARGET_PATH/lib" >> setup_env.sh
sudo -u "$username" echo -e "export UHD_INCLUDE_DIRS=$TARGET_PATH/include" >> setup_env.sh
sudo -u "$username" echo -e "" >> setup_env.sh
sudo -u "$username" echo -e "export SDR_TARGET_DIR=$TARGET_PATH" >> setup_env.sh
sudo -u "$username" echo -e "export SDR_SRC_DIR=$SRC_PATH" >> setup_env.sh

# add this environment setup script to bashrc unless it's already in there
if grep -q "$TARGET_PATH/setup_env.sh" ~/.bashrc; then
	:
else
	sudo -u "$username" echo -e "" >> ~/.bashrc
	sudo -u "$username" echo -e "########## points to local install of gnuradio and uhd" >> ~/.bashrc
	sudo -u "$username" echo -e "source $TARGET_PATH/setup_env.sh" >> ~/.bashrc
fi

# download the uhd images
sudo -u "$username" $TARGET_PATH/bin/uhd_images_downloader

# also add this environment setup script to bashrc
#sudo -u "$username" echo -e "" >> ~/.bashrc
#sudo -u "$username" echo -e "########## for compiling software that depends on UHD" >> ~/.bashrc
#sudo -u "$username" echo -e "export UHD_DIR=$TARGET_PATH" >> ~/.bashrc
#sudo -u "$username" echo -e "export UHD_LIBRARIES=$TARGET_PATH/lib" >> ~/.bashrc
#sudo -u "$username" echo -e "export UHD_INCLUDE_DIRS=$TARGET_PATH/include" >> ~/.bashrc

