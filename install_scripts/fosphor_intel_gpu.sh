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

# get username
username=$SUDO_USER

# you should be running as root; if you are not, quit
if [[ $EUID != 0 ]]; then
        echo "You are attempting to run the script root without root privileges."
        echo "Please run with sudo:"
        echo "  sudo ./fosphor_intel.sh"
        exit 1
fi

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
	echo "Got gen 7-9, installing ..."
# a 10th generation part
elif [[ $generation -eq 1 ]]; then
	install_beignet=false
	echo "Got gen 10, installing ..."
else
	echo "Couldn't identify processor generation"
	exit 1
fi

# number of cores to use for make
CORES=`nproc`

# there should also be an environment variable for the target and source paths
# if there is not, quit
if [[ -z "$SDR_TARGET_DIR" ]]; then
        echo "ERROR: \$SDR_TARGET_DIR not defined."
	echo "       Please make sure you are running sudo -E ./fosphor_intel.sh"
        echo "       You should run ./grc_from_source.sh before running this script."
        echo "       If you've already done that, you may need to open a new terminal"
        echo "       and try this script again."
        exit 1
fi

if [[ -z "$SDR_SRC_DIR" ]]; then
        echo "ERROR: \$SDR_SRC_DIR not defined."
	echo "       Please make sure you are running sudo -E ./fosphor_intel.sh"
        echo "       You should run ./grc_from_source.sh before running this script."
        echo "       If you've already done that, you may need to open a new terminal"
        echo "       and try this script again."
        exit 1
fi

if [[ -z "$GRC_38" ]]; then
        echo "ERROR: \$GRC_38 not defined."
	echo "       Please make sure you are running sudo -E ./fosphor_intel.sh"
        echo "       You should run ./grc_from_source.sh before running this script."
        echo "       If you've already done that, you may need to open a new terminal"
        echo "       and try this script again."
        exit 1
fi


# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
SRC_PATH=$SDR_SRC_DIR
TARGET_PATH=$SDR_TARGET_DIR
cd $SCRIPT_PATH

# install dependencies
if [[ $GRC_38 == true ]]; then
	# install QT5
	sudo apt -y install cmake xorg-dev libglu1-mesa-dev swig3.0 qt5-default swig wget
	# use a fosphor version compatible with cmake 3.8
	FOSPHOR_REF="2d4fe78b43bb67907722f998feeb4534ecb1efa8"
else
	# install QT4
	sudo apt -y install cmake xorg-dev libglu1-mesa-dev swig3.0 qt4-default \
		qtcreator python-qt4 swig wget
	# use a fosphor version compatible with cmake 2
	FOSPHOR_REF="5d8751ee411fb93ec8434dd2d6e7341988a91cb5"
fi
#sudo apt -y install mesa-opencl-icd

# after running the script, I also had to do the following with 3.8
#sudo apt install beignet
#sudo usermod -aG video $user_name

# install glfw
cd "$SRC_PATH" # custom block code lives at same level as gnuradio src
sudo -u "$username" git clone --recursive https://github.com/glfw/glfw
cd glfw
sudo -u "$username" git checkout $GLFW_VERSION
sudo -u "$username" git submodule update
# build it
sudo -u "$username" mkdir build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH -DBUILD_SHARED_LIBS=true ../ 
sudo -u "$username" make
sudo -u "$username" make install

# install gmmlib (???? Aren't we getting this from the binaries?)
#cd "$SRC_PATH" # custom block code lives at same level as gnuradio src
# run git clone as user so we don't have root owned files in the system
#sudo -u "$username" git clone https://github.com/intel/gmmlib
#cd gmmlib
#sudo -u "$username" mkdir -p build
#cd build
#sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH -DCMAKE_BUILD_TYPE=Release -DARCH=64 ../
#sudo -u "$username" make
#sudo -u "$username" make install

# install the five intel_deb packages (downloadable?)
cd "$SRC_PATH" # custom block code lives at same level as gnuradio src
sudo -u "$username" mkdir -p opencl_binaries
cd opencl_binaries
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/19.44.14658/intel-gmmlib_19.3.2_amd64.deb
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/19.44.14658/intel-igc-core_1.0.2714.1_amd64.deb
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/19.44.14658/intel-igc-opencl_1.0.2714.1_amd64.deb
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/19.44.14658/intel-opencl_19.44.14658_amd64.deb
sudo -u "$username" wget https://github.com/intel/compute-runtime/releases/download/19.44.14658/intel-ocloc_19.44.14658_amd64.deb
sudo dpkg -i *.deb

# final installation
sudo apt -y install ocl-icd-opencl-dev

# install beignet if necessary
if [ $install_beignet == true ]; then
	# first install dependencies for beignet
	sudo apt -y install cmake pkg-config python ocl-icd-dev libegl1-mesa-dev \
		ocl-icd-opencl-dev libdrm-dev libxfixes-dev libxext-dev \
	       	clang-3.6 libtinfo-dev libedit-dev zlib1g-dev
	sudo apt install beignet
	# removed llvm-3.6-dev and libclang-3.6-dev, not available via apt
	# next install llvm and clang
	#sudo -u "$username" git clone --recursive https://github.com/llvm/llvm-project.git
	#cd llvm-project
	#sudo -u "$username" git checkout $LLVM_VERSION
	#sudo -u "$username" git submodule update
	#sudo -u "$username" mkdir -p build
	#cd build
	#sudo -u "$username" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$TARGET_PATH ../llvm
	# also add -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi" ?
	#sudo -u "$username" make
	#sudo -u "$username" make install
fi

# now install gr-fosphor itself
cd "$SRC_PATH" # custom block code lives at same level as gnuradio src
sudo -u "$username" git clone --recursive git://git.osmocom.org/gr-fosphor
cd gr-fosphor
sudo -u "$username" git checkout $FOSPHOR_REF
sudo -u "$username" git submodule update

# need to use sed/awk to modify the following file:
# gr-fosphor/grc/fosphor_qt_sink_c.xml
# $(gui_hint()($win))</make>  BECOMES $(gui_hint() % $win)</make>
sed -i '/gui_hint()/ s/(\$win)/ % \$win/' grc/fosphor_qt_sink_c.xml
# gr-fosphor/lib/fosphor/private.h
# #define FLG_FOSPHOR_USE_CLGL_SHARING    (1<<0)  BECOMES  #define FLG_FOSPHOR_USE_CLGL_SHARING    (0<<0)
sed -i '/FLG_FOSPHOR_USE_CLGL_SHARING/ s/1<<0/0<<0/' lib/fosphor/private.h

sudo -u "$username" mkdir build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH ../
sudo -u "$username" make
sudo -u "$username" make install

# may help
sudo usermod -aG video "$username"
