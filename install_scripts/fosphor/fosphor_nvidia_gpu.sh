#!/bin/bash
# This script installs gr-gsm from source. It is intended for
# execution AFTER the grc_from_source.sh script has been run and will
# install to the same target directory used for that process.
#
# This script depends on environment variables that were created during
# the gnuradio installation process, so the script must be run WITH
# sudo:
# sudo -E ./fosphor_nvidia_gpu.sh

# first get a few common functions:
source ../common/common_functions.sh

# call function to get globals: script_path, script_name, user_name, cores
get_basic_info

# check if running script as root, else exit
exit_unless_root

# check that the necessary environment vars in place, else exit
check_env_vars

glfw_repo=https://github.com/glfw/glfw
glfw_ref=3.3.1
fosphor_repo=git://git.osmocom.org/gr-fosphor
fosphor_ref=defdd4aca6cd157ccc3b10ea16b5b4f552f34b96 

# install dependencies
sudo apt -y install cmake 
sudo apt -y install xorg-dev 
sudo apt -y install libglu1-mesa-dev 

# install glfw (needs extra cmake arg)
clone_and_build $glfw_repo $glfw_ref sudo -DBUILD_SHARED_LIBS=true

# final installation
sudo apt -y install nvidia-opencl-dev
sudo apt -y install opencl-headers
sudo apt -y install clinfo

# now install gr-fosphor itself
cd $SDR_SRC_DIR # custom block code lives at same level as gnuradio src
sudo -u "$username" git clone --recursive $fosphor_repo 
cd gr-fosphor
sudo -u "$username" git checkout $fosphor_ref
sudo -u "$username" git submodule update

# need to use sed/awk to modify the following file:
# gr-fosphor/lib/fosphor/private.h
# #define FLG_FOSPHOR_USE_CLGL_SHARING    (1<<0)  BECOMES  #define FLG_FOSPHOR_USE_CLGL_SHARING    (0<<0)
sed -i '/FLG_FOSPHOR_USE_CLGL_SHARING/ s/1<<0/0<<0/' lib/fosphor/private.h

sudo -u "$username" mkdir build
cd build
sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$SDR_TARGET_DIR ../
sudo -u "$username" make $CORES
sudo -u "$username" make install


echo "NOTE: to verify if gr-fosphor is working, please connect an SDR and"
echo "      run the following flowgraph:"
echo "      ~/install/grc-install/grc/fosphor/fosphor-example.grc"
echo ""
echo "      if foshphor does not work, please check that you have the"
echo "      latest nVidia drivers installed"
echo ""
echo "      for more details, please see www.factorialabs.com"
