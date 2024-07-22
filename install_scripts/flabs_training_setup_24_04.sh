#!/usr/bin/bash -x

# basic setup for a new ubuntu 24.04 machine

# check for OS version
ubuntu_version_str=$(hostnamectl | grep -i Ubuntu)
regex_str='Ubuntu\s([0-9]+\.[0-9]+)'
if [[ ! "$ubuntu_version_str" =~ $regex_str ]]; then
  echo "ERROR: Not running Ubuntu. Install scripts will require"
  echo "       manual edits to run. Proceed at your own risk."
  exit 1
else
  ubuntu_version=${BASH_REMATCH[1]}
  if [[ $ubuntu_version == "24.04" ]]; then
    echo "Detected Ubuntu 24.04 - proceeding with installation"
  else
    echo "This script is intended only for use with Ubuntu 24.04"
    echo "Exiting..."
  fi
fi
echo "got here"

echo "**** Updating existing packages..."
sudo apt update
sudo apt -y upgrade

echo "**** Installing prereqs for building OOT modules"
sudo apt -y install vim git curl wget xz-utils python3-pip
sudo apt -y install libusb-1.0-0-dev cmake libncurses-dev libtecla1t64 libtecla-dev pkg-config 
sudo apt -y install doxygen help2man pandoc
sudo apt -y install gobject-introspection libboost-all-dev libsctp-dev liborc-0.4-dev \
intel-opencl-icd clinfo libfreetype6-dev libglfw3-dev libqt5opengl5-dev ocl-icd-opencl-dev \
opencl-headers graphviz liblog4cpp5-dev qttools5-dev python3-construct python3-websocket \
libcanberra-gtk-module

echo "**** Installing GNU Radio"
sudo apt install -y gnuradio

echo "**** Installing UHD Drivers"
sudo apt install -y libuhd-dev uhd-host
sudo uhd_images_downloader

echo "**** Installing PlutoSDR Drivers"
sudo apt install -y libiio-utils bison flex cmake
echo "**** Copying udev rules for SDR hardware"

echo "**** Installing LimeSDR Drivers"
sudo apt install -y limesuite
sudo apt install -y gr-limesdr

(
  cd ../udev-rules || exit
  sudo cp 20-rtlsdr.rules /etc/udev/rules.d/.
  sudo cp 53-adi-m2k-usb.rules /etc/udev/rules.d/.
  sudo cp 53-adi-plutosdr-usb.rules /etc/udev/rules.d/.
  sudo cp 53-hackrf.rules /etc/udev/rules.d/.
  sudo cp 64-limesuite.rules /etc/udev/rules.d/.
  sudo cp 88-nuand.rules /etc/udev/rules.d/.
  sudo cp uhd-usrp.rules /etc/udev/rules.d/.
)

mkdir -p ~/install
cd ~/install || exit
cpu_count=$(nproc)

echo "**** Building gr-satellites"
(
git clone https://github.com/daniestevez/gr-satellites
cd gr-satellites || exit
git checkout maint-3.10
mkdir -p build
cd build || exit
cmake ..
make -j$cpu_count
sudo make install
sudo ldconfig
)

echo "**** Building gr-reveng"
(
git clone https://github.com/paulgclark/gr-reveng
cd gr-reveng || exit
git checkout maint-3.9 
mkdir -p build
cd build || exit
cmake ..
make -j$cpu_count
sudo make install
sudo ldconfig
)

echo "**** Building gr-fosphor"
(
git clone https://gitea.osmocom.org/sdr/gr-fosphor.git
cd gr-fosphor || exit
mkdir -p build
cd build || exit
cmake ..
make -j$cpu_count
sudo make install
sudo ldconfig
)

echo "**** Installing PyCharm Community Edition"
sudo snap install pycharm-community --classic

echo "**** Installing Universal Radio Hacker"
sudo snap install urh

echo "**********************************************************************"
echo "Installation complete. You must now reboot, and at the login screen,"
echo "click your user icon and then the settings icon in the bottom right."
echo "Select \"Ubuntu on Xorg\" and then proceed with your login."
echo "You will only need to do this once."
echo "**********************************************************************"
