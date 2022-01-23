#!/bin/bash
# This script will install gnuradio 3.7.11, applying a necessary patch.
# It will also install the necessary files to get the USRP hardware
# working. Finally, the gr-reveng OOT blocks are installed.

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
# get directory into which git project was cloned
cd ../..
INSTALL_PATH=`pwd`
cd "$SCRIPT_PATH"

# get username
username=$SUDO_USER

# update the system before beginning the install process
sudo apt update
sudo apt -y upgrade

# install gnuradio
sudo apt -y install libcanberra-gtk-module
sudo apt -y install xterm
# the following command will generate an xml parser error, you can ignore it
sudo apt -y install gnuradio

# install rules files for non-root access to USB
# note: if you run the install process with our SDR plugged in,
#       you will need to unplug and replug
cd "$SCRIPT_PATH"
sudo cp ../udev-rules/uhd-usrp.rules /etc/udev/rules.d/.
sudo cp ../udev-rules/53-hackrf.rules /etc/udev/rules.d/.
sudo cp ../udev-rules/64-limesuite.rules /etc/udev/rules.d/.
sudo cp ../udev-rules/88-nuand.rules /etc/udev/rules.d/.
sudo cp ../udev-rules/20-rtlsdr.rules /etc/udev/rules.d/.
sudo udevadm control --reload-rules

# call uhd image download
sudo uhd_images_downloader

# create grc config file with entry to resolve xterm warning
sudo -u "$username" mkdir ~/.gnuradio # this directory will not exist unless grc already run
sudo -u "$username" touch ~/.gnuradio/gnuradio.conf
sudo -u "$username" echo -e "[grc]" >> ~/.gnuradio/gnuradio.conf
sudo -u "$username" echo -e "xterm_executable=/usr/bin/xterm" >> ~/.gnuradio/gnuradio.conf
