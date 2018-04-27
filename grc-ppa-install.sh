# start with update of existing apps
sudo apt update
sudo apt upgrade

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

# install soapy sw
sudo apt install -y soapysdr
sudo apt install -y soapysdr-module-lms7

# install gnuradio and osmo
sudo apt install -y gnuradio
sudo apt install -y gr-osmosdr
sudo apt install -y hackrf

# install rules files for non-root access to USB
# note: if you run the install process with our SDR plugged in,
#       you will need to unplug and replug
sudo cp ./udev-rules/53-hackrf.rules /etc/udev/rules.d/.
sudo cp ./udev-rules/64-limesuite.rules /etc/udev/rules.d/.
sudo cp ./udev-rules/88-nuand.rules /etc/udev/rules.d/.
sudo cp ./udev-rules/uhd-usrp.rules /etc/udev/rules.d/.
sudo restart udev
