#!/bin/bash
# Best practice is to create an install directory off your home, then 
# cloning the git repo as follows:
# cd
# mkdir install
# cd install
# git clone https://github.com/paulgclark/grc-install
# 
# NOTE: You should run the gnuradio installation scripts BEFORE
# you run this one:
# sudo ./grc_from_source.sh
#
# You should then run this script in place with the following commands:
# cd grc-install/install-scripts
# sudo ./fosphor_intel.sh
# 
# If you run this script from another directory, you will break some
# relative path links and the install will fail.

CPU_MFG="Intel"
GLFW_VERSION="3.3.1"
LLVM_VERSION="9.0.1"
FOSPHOR_VER_38="2d4fe78b43bb67907722f998feeb4534ecb1efa8"
FOSPHOR_VER_37="ffe4a1d7bdef4863e42fe70a7ed58f8c4d682ccd"

# first get a few common functions:
source ../common/common_functions.sh

# call function to get globals: script_path, script_name, user_name, cores
get_basic_info

# check if running script as root, else exit
exit_unless_root

# check that the necessary environment vars in place, else exit
check_env_vars

# check that the CPU manufacturer is correct
cpu_version_str=`sudo dmidecode -t 4 | grep -i version`
if [[ $cpu_version_str != *$CPU_MFG* ]]; then
	echo "This script is intended for use on $CPU_MFG-based systems only."
	exit 1
fi
#set -x

# check that we are dealing with a core processor (i3/i5/i7/i9)
regex_str='i([3579])-([0-9])[0-9]{3}'
if [[ ! "$cpu_version_str" =~ $regex_str ]]; then
	echo "You do not have an Intel Core series processor. This script"
	echo "is not able to auto-detect your processor generation. You"
	echo "may try to manually edit the script to get it to work."
	exit 1
fi

generation=${BASH_REMATCH[2]}

# check if the processor generation is between 3 and 6
if [[ $generation -ge 3 && $generation -le 6 ]]; then
	install_beignet=true
	echo "Got gen 3-6, installing beignet"
# is it 7 or greater?
elif [[ $generation -ge 7 && $generation -le 9 ]]; then
	install_beignet=false
	echo "Got gen 7-9, installing without beignet"
# a 10th generation part
elif [[ $generation -eq 1 ]]; then
	install_beignet=false
	echo "Got gen 10 or greater, installing without beignet"
else
	echo "Couldn't identify processor generation, exiting..."
	exit 1
fi

# get current directory (assuming the script is run from local dir)
cd $script_path

# install dependencies
if [[ $GRC_38 == true ]]; then
	# install QT5
	sudo apt -y install cmake xorg-dev libglu1-mesa-dev swig3.0 qt5-default swig wget
	# use a fosphor version compatible with cmake 3.8
	FOSPHOR_REF=$FOSPHOR_VER_38
else
	# install QT4
	sudo apt -y install cmake xorg-dev libglu1-mesa-dev swig3.0 qt4-default \
		qtcreator python-qt4 swig wget
	# use a fosphor version compatible with cmake 2
	FOSPHOR_REF=$FOSPHOR_VER_37
fi


# install glfw
cd "$SDR_SRC_DIR" # custom block code lives at same level as gnuradio src
sudo -u "$username" git clone --recursive https://github.com/glfw/glfw
cd glfw
sudo -u "$username" git checkout $GLFW_VERSION
sudo -u "$username" git submodule update
# build it
sudo -u "$username" mkdir build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$SDR_TARGET_DIR -DBUILD_SHARED_LIBS=true ../ 
sudo -u "$username" make
sudo -u "$username" make install


# install the five intel_deb packages (downloadable?)
cd "$SDR_SRC_DIR" # custom block code lives at same level as gnuradio src
sudo -u "$username" mkdir -p opencl_binaries
cd opencl_binaries
# updated as of Sep 2021
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/21.09.19150/intel-gmmlib_20.3.2_amd64.deb
sudo -u "$username" wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.6410/intel-igc-core_1.0.6410_amd64.deb
sudo -u "$username" wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.6410/intel-igc-opencl_1.0.6410_amd64.deb
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/21.09.19150/intel-opencl_21.09.19150_amd64.deb
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/21.09.19150/intel-ocloc_21.09.19150_amd64.deb
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/21.09.19150/intel-level-zero-gpu_1.0.19150_amd64.deb
sudo dpkg -i *.deb


# final installation
sudo apt -y install ocl-icd-opencl-dev

# install beignet if necessary
if [ $install_beignet == true ]; then
	# first install dependencies for beignet
	sudo apt -y install cmake pkg-config python ocl-icd-dev libegl1-mesa-dev \
		ocl-icd-opencl-dev libdrm-dev libxfixes-dev libxext-dev \
	       	clang-3.6 libtinfo-dev libedit-dev zlib1g-dev
	sudo apt -y install llvm-3.9-dev libclang-3.9-dev
	sudo apt -y install beignet
fi

# now install gr-fosphor itself
cd "$SDR_SRC_DIR" # custom block code lives at same level as gnuradio src
sudo -u "$username" git clone --recursive git://git.osmocom.org/gr-fosphor
cd gr-fosphor
sudo -u "$username" git checkout $FOSPHOR_REF
sudo -u "$username" git submodule update

# for gnuradio 3.7.x, we need to modify an XML file
if [[ GRC_38 == false ]]; then
	# need to use sed/awk to modify the following file:
	# gr-fosphor/grc/fosphor_qt_sink_c.xml
	# $(gui_hint()($win))</make>  BECOMES $(gui_hint() % $win)</make>
	sed -i '/gui_hint()/ s/(\$win)/ % \$win/' grc/fosphor_qt_sink_c.xml
fi

# gr-fosphor/lib/fosphor/private.h
# #define FLG_FOSPHOR_USE_CLGL_SHARING    (1<<0)  BECOMES  #define FLG_FOSPHOR_USE_CLGL_SHARING    (0<<0)
sed -i '/FLG_FOSPHOR_USE_CLGL_SHARING/ s/1<<0/0<<0/' lib/fosphor/private.h

sudo -u "$username" mkdir build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$SDR_TARGET_DIR \
                          -DCMAKE_BUILD_TYPE=RELEASE ../
sudo -u "$username" make
sudo -u "$username" make install

# may help
sudo usermod -aG video "$username"
