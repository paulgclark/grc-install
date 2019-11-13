#!/bin/bash
# Best practice is to create an install directory off your home, then 
# cloning the git repo as follows:
# cd
# mkdir install
# cd install
# git clone https://github.com/paulgclark/grc-install
# 
# You should then run this script in place with the following commands:
# cd grc-install/install-scripts
# sudo ./grc_install_flabs_class.sh
# 
# If you run this script from another directory, you will break some
# relative path links and the install will fail.

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
sudo apt -y install git
cd "$SCRIPT_PATH"
sudo cp ../udev-rules/uhd-usrp.rules /etc/udev/rules.d/.
sudo cp ../udev-rules/53-hackrf.rules /etc/udev/rules.d/.
sudo cp ../udev-rules/64-limesuite.rules /etc/udev/rules.d/.
sudo cp ../udev-rules/88-nuand.rules /etc/udev/rules.d/.
sudo cp ../udev-rules/20-rtlsdr.rules /etc/udev/rules.d/.
sudo udevadm control --reload-rules

# call uhd image download
sudo uhd_images_downloader

# install custom blocks
sudo apt -y install cmake
sudo apt -y install swig
cd "$INSTALL_PATH" # the custom block code will live at the same level as grc-install
# run git clone as user so we don't have root owned files in the system
sudo -u "$username" git clone https://github.com/paulgclark/gr-reveng
cd gr-reveng
sudo -u "$username" mkdir build
cd build
sudo -u "$username" cmake ../
sudo -u "$username" make
sudo make install
sudo ldconfig

# create grc config file with entry to resolve xterm warning
sudo -u "$username" mkdir ~/.gnuradio # this directory will not exist unless grc already run
sudo -u "$username" touch ~/.gnuradio/gnuradio.conf
sudo -u "$username" echo -e "[grc]" >> ~/.gnuradio/gnuradio.conf
sudo -u "$username" echo -e "xterm_executable=/usr/bin/xterm" >> ~/.gnuradio/gnuradio.conf
cd "$SCRIPT_PATH"
sudo -u "$username" cp ../misc/config.conf ~/.gnuradio/.

# installing Python code for use in some exercises
cd "$INSTALL_PATH" # the class-specific Python code will live at the same level as grc-install
sudo -u "$username" git clone https://github.com/paulgclark/rf_utilities
sudo -u "$username" echo "" >> ~/.bashrc
sudo -u "$username" echo "################################" >> ~/.bashrc
sudo -u "$username" echo "# Custom code for gnuradio class" >> ~/.bashrc
sudo -u "$username" echo "export PYTHONPATH=$PYTHONPATH:"INSTALL_PATH"/rf_utilities"  >> ~/.bashrc
sudo -u "$username" echo "" >> ~/.bashrc

# other useful stuff
sudo apt install -y vim
sudo snap install pycharm-community --classic

# run gnuradio-companion with FM radio loaded for test
cd "$SCRIPT_PATH"
sudo -u "$username" gnuradio-companion ../grc/uhd-test/fm_receiver_hardware_uhd.grc
