# grc-install
This repo contains files for installing and testing gnuradio-companion
with support for the UHD drivers. There are also a few additional
scripts for installing other useful software.

## Prerequisites
These scripts have been tested on Ubuntu 18.04.3 LTS. I can't make any 
promises for other distros or versions. I've tested on both fresh installs
as well as not-so-fresh and haven't had any problems. If your machine
does already have a version of gnuradio or the uhd drivers, however, 
you may want to disable (if you have a PyBombs installation) or remove it.

## General Approach
These scripts will download the source code for uhd, gnuradio and other
software and automatically build and compile them to a target directory.
Although I'm not using PyBombs, this is a similar approach to what it 
does. This approach allows you to maintain multiple gnuradio/uhd 
installs and easily switch between them as needed. It's also a lot easier
to recover from a botched installation (just rm -r the target and start
over).

## Basic Setup
Before running any scripts, you should create directory for all the 
source code as well as the target. Do this with:
```
cd
mkdir install
cd install
```
Then install git and use it to grab this repo.
```
sudo apt -y install git
git clone https://github.com/paulgclark/grc-install
```
Then navigate to the first script and run it:
```
cd grc-install/install_scripts
sudo ./grc_from_source.sh
```
This will take a while, probably 30-60 minutes. If you want to tinker with
the script before running, you can bump up the number of cores used in the
make step to match your multi-core monster rig. 

## Testing The Build
You will need to open a new terminal window. Then type:
```
cd install/grc-install/grc/uhd-test
gnuradio-companion fm_receiver_hardware_uhd_3_7_13.grc
```
If all has gone well, you should see the gnuradio-companion interface,
pre-populated with a flowgraph. Attach your Ettus hardware to your
computer via USB3 with an 100 MHz-capable antenna on your TRX port. You
can then run the flowgraph by clicking the execute button from the 
toolbar. If all has gone well, you should see a Frequency plot. You can 
tune to one of the spikes there by typing the corresponding frequency 
into the entry labeled "freq". If you know there's a station at 97.1, 
for example, you can type "97.1M" into the box and hit enter.

## Installation Scripts
These scripts should all be run with sudo, as I've designed them not to
require entering in the password throughout execution. I've used the -u
option frequently to keep a bunch of root-owned files from messing up
your file system.

sudo ./install_scripts/grc_from_source.sh
- installs gnuradio 3.7.13.5, the uhd drivers and other things required 
to make them work
- if you want a different version of either gnuradio or uhd, you can set 
the environment variable near the top of the script accordingly

sudo ./install_scripts/grc_simple_install.sh
- a quicker and simpler script that installs 3.7.11 from the repository
- this install is not to a target but is a global install
- this script is a quick and dirty standalone and shouldn't be expected
to work with any of the others here

sudo ./install_scripts/fosphor_install.sh
- installs OpenCL and gr-fosphor from source to your target
- this may or may not work depending on your hardware
- I was successful on Intel machines with integrated graphics

sudo ./install_scripts/grc_install_flabs_class.sh
- contains additional software for those taking a Factoria Labs SDR class
- you may find it useful even if you're not taking a class...

## Test Flowgraphs
./grc/uhd-test  
./grc/hackrf-test  
./grc/lime-test  

The latter two won't be so useful until I restore the hackrf and limesdr
installation scripts, but each of these directories has some flowgraphs
you can use to check that your system is running OK. The ook and gfsk
flowgraphs require two sets of gnuradio-computer + sdr-hardware.
