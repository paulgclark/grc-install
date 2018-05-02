# start with update of existing apps
sudo apt update
sudo apt -y upgrade

# add repositories for bladerf, ettus, gqrx and myriadrf
sudo add-apt-repository -y ppa:bladerf/bladerf
sudo add-apt-repository -y ppa:ettusresearch/uhd
sudo add-apt-repository -y ppa:myriadrf/drivers
sudo add-apt-repository -y ppa:myriadrf/gnuradio
sudo add-apt-repository -y ppa:gqrx/gqrx-sdr
sudo apt update

# install the lime sw
sudo apt install -y limesuite
sudo apt install -y liblimesuite-dev
sudo apt install -y limesuite-udev
sudo apt install -y limesuite-images

# install soapy sw (choose one of the following two depending on your OS)
sudo apt install -y soapysdr # for Ubuntu 16.04
#sudo apt install -y soapysdr-tools # for Ubuntu 18.04

# same for both OS's
sudo apt install -y soapysdr-module-lms7

# install gnuradio and osmo
sudo apt install -y gnuradio
sudo apt install -y gr-osmosdr
sudo apt install -y hackrf
sudo apt install -y libcanberra-gtk-module # needed for 18.04

# install rules files for non-root access to USB
# note: if you run the install process with our SDR plugged in,
#       you will need to unplug and replug
sudo cp ./udev-rules/53-hackrf.rules /etc/udev/rules.d/.
sudo cp ./udev-rules/64-limesuite.rules /etc/udev/rules.d/.
sudo cp ./udev-rules/88-nuand.rules /etc/udev/rules.d/.
sudo cp ./udev-rules/uhd-usrp.rules /etc/udev/rules.d/.
sudo udevadm control --reload-rules

# create grc config file with entry to resolve xterm warning
mkdir ~/.gnuradio # this directory will not exist unless grc already run
echo -e "[grc]\nxterm_executable=/usr/bin/xterm" > ~/.gnuradio/grc.conf
cp ./misc/config.conf ~/.gnuradio/.

