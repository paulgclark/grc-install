#!/bin/bash
# This script installs the uhd drivers and gnuradio from source.

UHD_VERSION="v3.14.1.1"
GRC_VERSION="v3.7.13.5"

sudo apt update
sudo apt -y upgrade

sudo apt-get -y install git swig cmake doxygen build-essential libboost-all-dev libtool libusb-1.0-0 libusb-1.0-0-dev libudev-dev libncurses5-dev libfftw3-bin libfftw3-dev libfftw3-doc libcppunit-1.14-0 libcppunit-dev libcppunit-doc ncurses-bin cpufrequtils python-numpy python-numpy-doc python-numpy-dbg python-scipy python-docutils qt4-bin-dbg qt4-default qt4-doc libqt4-dev libqt4-dev-bin python-qt4 python-qt4-dbg python-qt4-dev python-qt4-doc libqwt6abi1 libncurses5 libncurses5-dbg libfontconfig1-dev libxrender-dev libpulse-dev g++ automake autoconf python-dev libusb-dev fort77 libsdl1.2-dev python-wxgtk3.0 ccache python-opengl libgsl-dev python-cheetah python-mako python-lxml qt4-dev-tools libqwtplot3d-qt5-dev pyqt4-dev-tools python-qwt5-qt4 wget libxi-dev gtk2-engines-pixbuf r-base-dev python-tk liborc-0.4-0 liborc-0.4-dev libasound2-dev python-gtk2 libzmq3-dev libzmq5 python-requests python-sphinx libcomedi-dev python-zmq libqwt-dev python-six libgps-dev libgps23 gpsd gpsd-clients python-gps python-setuptools libcanberra-gtk-module xterm

# setup source and target directories
mkdir -p ~/install
mkdir -p ~/install/src
mkdir -p ~/install/sdr

# get the repo
cd ~/install/src
git clone --recursive https://github.com/EttusResearch/uhd

# checkout the more recent stable release
cd ~/install/src/uhd
git checkout $UHD_VERSION
git submodule update

# build UHD
cd host
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=~/install/sdr ../
make -j3
make install

# copy UHD rules file
sudo cp ~/install/src/uhd/host/utils/uhd-usrp.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger

# resolve thread priority issue
sudo groupadd usrp
sudo usermod -aG usrp $USER
sudo sh -c "echo '@usrp\t-\trtprio\t99' >> /etc/security/limits.conf"

# now build gnuradio from source
cd ~/install/src
git clone --recursive https://github.com/gnuradio/gnuradio

# checkout the intended release
cd ~/install/src/gnuradio
git checkout $GRC_VERSION 
git submodule update

# build gnuradio
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=~/install/sdr -DUHD_DIR=~/install/sdr/lib/cmake/uhd/ -DUHD_INCLUDE_DIRS=~/install/sdr/include/ -DUHD_LIBRARIES=~/install/sdr/lib/libuhd.so ../
make -j3
make install

# create the environment file
cd ~/install/sdr
touch setup_env.sh

echo -e "LOCALPREFIX=~/install/sdr" >> setup_env.sh
echo -e "export PATH=\$LOCALPREFIX/bin:$PATH" >> setup_env.sh
echo -e "export LD_LOAD_LIBRARY=\$LOCALPREFIX/lib:\$LD_LOAD_LIBRARY" >> setup_env.sh
echo -e "export LD_LIBRARY_PATH=\$LOCALPREFIX/lib:\$LD_LIBRARY_PATH" >> setup_env.sh
echo -e "export PYTHONPATH=\$LOCALPREFIX/lib/python2.7/site-packages:\$PYTHONPATH" >> setup_env.sh
echo -e "export PYTHONPATH=\$LOCALPREFIX/lib/python2.7/dist-packages:\$PYTHONPATH" >> setup_env.sh
echo -e "export PKG_CONFIG_PATH=\$LOCALPREFIX/lib/pkgconfig:\$PKG_CONFIG_PATH" >> setup_env.sh
echo -e "export UHD_RFNOC_DIR=\$LOCALPREFIX/share/uhd/rfnoc/" >> setup_env.sh
echo -e "export UHD_IMAGES_DIR=\$LOCALPREFIX/share/uhd/images" >> setup_env.sh

# add this environment setup script to bashrc
echo -e "" >> ~/.bashrc
echo -e "########## points to local install of gnuradio and uhd" >> ~/.bashrc
echo -e "source ~/install/sdr/setup_env.sh" >> ~/.bashrc

# now source the environment for the remainder of this script
source ~/install/sdr/setup_env.sh

# download the uhd images
uhd_images_downloader

