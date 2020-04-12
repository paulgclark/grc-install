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
# - gnuradio version ("3.7" or "3.8")
# - install path

# These are the versions that will be installed for 3.7 and 3.8
# If you want to install a different version, change these variables
GRC_37_VERSION="v3.7.13.5"
GRC_38_VERSION="v3.8.1.0"
# If you want to install different versions of uhd, you can see a list of 
# releases on github, or by running the following command after the recursive
# clone operation:
# git tag -l
UHD_VERSION="v3.15.0.0"

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
# get udev file directory
cd ../udev-rules
UDEV_FILES_PATH=$PWD

# get username and home dir (~ is causing problems without -E now)
username=$SUDO_USER
homedir="/home/$username" 

# number of cores to use for make
CORES=`nproc`

# you should be running as root; if you are not, quit
if [[ $EUID != 0 ]]; then
        echo "You are attempting to run the script without root privileges."
        echo "Please run with sudo:"
        echo "  sudo ./grc_from_source.sh"
        exit 1
fi

# determine if we are installing 3.7 (default) or 3.8
if [ -z "$1" ]; then
	GRC_38=false
elif [ "$1" == "3.7" ]; then
	GRC_38=false
elif [ "$1" == "3.8" ]; then
	GRC_38=true
else
	echo "Invalid GRC version. Please enter either \"3.7\" or \"3.8\""
	exit 1
fi

# check if arg been passed for install path, else use ~/install
if [ -z "$2" ]; then
	INSTALL_PATH="$homedir/install"
else
	INSTALL_PATH=$2
fi

# setup the target and source paths off the install directory
TARGET_PATH=$INSTALL_PATH/sdr
SRC_PATH=$INSTALL_PATH/src


# install dependencies
sudo apt update
sudo apt -y upgrade

# common dependencies
sudo apt -y install git cmake g++ libboost-all-dev build-essential libtool
sudo apt -y install automake autoconf libudev-dev doxygen
sudo apt -y install libusb-dev libusb-1.0-0-dev libusb-1.0-0 
sudo apt -y install python-setuptools
sudo apt -y install libfftw3-dev libfftw3-bin libfftw3-doc
sudo apt -y install libcppunit-dev libcppunit-doc
sudo apt -y install ncurses-bin
sudo apt -y install libfontconfig1-dev libxrender-dev libpulse-dev
sudo apt -y install fort77 ccache libsdl1.2-dev libgsl-dev
sudo apt -y install wget xterm libcanberra-gtk-module cpufrequtils
sudo apt -y install libxi-dev r-base-dev liborc-0.4-0 liborc-0.4-dev
sudo apt -y install libasound2-dev
sudo apt -y install libzmq3-dev libzmq5
sudo apt -y install libcomedi-dev
sudo apt -y install libgps-dev gpsd gpsd-clients

if [ "$GRC_38" = true ]; then
	sudo apt -y install libgmp-dev swig python3-numpy python3-mako \
		python3-sphinx python3-lxml libqwt-qt5-dev \
		libqt5opengl5-dev python3-pyqt5 liblog4cpp5-dev \
		python3-yaml python3-click python3-click-plugins python3-zmq \
		python3-setuptools python3-opengl python3-pip
else # install the GRC 3.7 dependencies
	sudo apt -y install python-dev python-mako \
		python-numpy python-wxgtk3.0 python-sphinx python-cheetah \
		swig libqt4-opengl-dev python-qt4 libqwt-dev python-pip \
		python-gtk2 python-lxml pkg-config python-sip-dev \
		python-opengl python-tk python-requests python-six python-gps
fi

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

# copy rules file for UHD (and other devices) for SDR access in user mode
sudo cp $UDEV_FILES_PATH/* /etc/udev/rules.d/
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
if [ "$GRC_38" = true ]; then
	sudo -u "$username" git checkout $GRC_38_VERSION
else
	sudo -u "$username" git checkout $GRC_37_VERSION
fi
sudo -u "$username" git submodule update

# build gnuradio
sudo -u "$username" mkdir -p build
cd build
if [ "$GRC_38" = true ]; then
	sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH \
		-DUHD_DIR=$TARGET_PATH/lib/cmake/uhd/ \
		-DUHD_INCLUDE_DIRS=$TARGET_PATH/include/ \
		-DUHD_LIBRARIES=$TARGET_PATH/lib/libuhd.so \
		-DPYTHON_EXECUTABLE=/usr/bin/python3 \
		../
else
	sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH \
		-DUHD_DIR=$TARGET_PATH/lib/cmake/uhd/ \
		-DUHD_INCLUDE_DIRS=$TARGET_PATH/include/ \
		-DUHD_LIBRARIES=$TARGET_PATH/lib/libuhd.so ../
fi
sudo -u "$username" make -j$CORES
sudo -u "$username" make install

# create the environment file
cd $TARGET_PATH
sudo -u "$username" touch setup_env.sh

sudo -u "$username" echo -e "LOCALPREFIX=$TARGET_PATH" >> setup_env.sh
sudo -u "$username" echo -e "export PATH=\$LOCALPREFIX/bin:\$PATH" >> setup_env.sh
sudo -u "$username" echo -e "export LD_LOAD_LIBRARY=\$LOCALPREFIX/lib:\$LD_LOAD_LIBRARY" >> setup_env.sh
sudo -u "$username" echo -e "export LD_LIBRARY_PATH=\$LOCALPREFIX/lib:\$LD_LIBRARY_PATH" >> setup_env.sh
if [ "$GRC_38" = true ]; then
	sudo -u "$username" echo -e "export PYTHONPATH=\$LOCALPREFIX/lib/python3.8/site-packages:\$PYTHONPATH" >> setup_env.sh
	sudo -u "$username" echo -e "export PYTHONPATH=\$LOCALPREFIX/lib/python3/dist-packages:\$PYTHONPATH" >> setup_env.sh
else
	sudo -u "$username" echo -e "export PYTHONPATH=\$LOCALPREFIX/lib/python2.7/site-packages:\$PYTHONPATH" >> setup_env.sh
	sudo -u "$username" echo -e "export PYTHONPATH=\$LOCALPREFIX/lib/python2.7/dist-packages:\$PYTHONPATH" >> setup_env.sh
fi
sudo -u "$username" echo -e "export PKG_CONFIG_PATH=\$LOCALPREFIX/lib/pkgconfig:\$PKG_CONFIG_PATH" >> setup_env.sh
sudo -u "$username" echo -e "export UHD_RFNOC_DIR=\$LOCALPREFIX/share/uhd/rfnoc/" >> setup_env.sh
sudo -u "$username" echo -e "export UHD_IMAGES_DIR=\$LOCALPREFIX/share/uhd/images" >> setup_env.sh
sudo -u "$username" echo -e "" >> setup_env.sh
sudo -u "$username" echo -e "########## for compiling software that depends on UHD" >> setup_env.sh
sudo -u "$username" echo -e "export UHD_DIR=\$LOCALPREFIX" >> setup_env.sh
sudo -u "$username" echo -e "export UHD_LIBRARIES=\$LOCALPREFIX/lib" >> setup_env.sh
sudo -u "$username" echo -e "export UHD_INCLUDE_DIRS=\$LOCALPREFIX/include" >> setup_env.sh
sudo -u "$username" echo -e "" >> setup_env.sh
sudo -u "$username" echo -e "########## these vars assist in follow-on install scripts" >> setup_env.sh
sudo -u "$username" echo -e "export SDR_TARGET_DIR=\$LOCALPREFIX" >> setup_env.sh
sudo -u "$username" echo -e "export SDR_SRC_DIR=$SRC_PATH" >> setup_env.sh
sudo -u "$username" echo -e "export GRC_38=$GRC_38" >> setup_env.sh

# add this environment setup script to bashrc unless it's already in there
if grep -q "$TARGET_PATH/setup_env.sh" $homedir/.bashrc; then
	:
else
	sudo -u "$username" echo -e "" >> $homedir/.bashrc
	sudo -u "$username" echo -e "########## points to local install of gnuradio and uhd" >> $homedir/.bashrc
	sudo -u "$username" echo -e "source $TARGET_PATH/setup_env.sh" >> $homedir/.bashrc
fi


# download the uhd images
sudo -u "$username" $TARGET_PATH/bin/uhd_images_downloader

