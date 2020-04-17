#!/bin/bash
# This script installs the limesdr tools from source. It is intended for
# execution AFTER the grc_from_source.sh script has been run and will
# install to the same target directory used for that process.
#
# This script depends on environment variables that were created during
# the gnuradio installation process, so the script must be run WITHOUT
# sudo:
# ./lime_from_source

# first get a common function
source ./common/common_functions.sh

# get current directory (assuming the script is run from local dir)
SCRIPT_PATH=$PWD
SCRIPT_NAME=${0##*/}
cd ../udev-rules
UDEV_RULES_PATH=$PWD

# you should not be root, if you are, quit
if [[ $EUID == 0 ]]; then
	echo "You are attempting to run the script as root."
	echo "Please do not run with sudo, but simply run:"
	echo "  ./$SCRIPT_NAME"
	exit 1
fi

# there should also be an environment variable for the target and source paths
# if there is not, quit
if [[ -z "$SDR_TARGET_DIR" ]]; then
        echo "ERROR: \$SDR_TARGET_DIR not defined."
	echo "       You should run ./grc_from_source.sh before running this script."
	echo "       If you've already done that, you may need to open a new terminal"
	echo "       and try this script again."
	exit 1
fi

if [[ -z "$SDR_SRC_DIR" ]]; then
        echo "ERROR: \$SDR_SRC_DIR not defined."
	echo "       You should run ./grc_from_source.sh before running this script."
	echo "       If you've already done that, you may need to open a new terminal"
	echo "       and try this script again."
	exit 1
fi

# number of cores to use for make
CORES=`nproc`

SOAPY_URL="https://github.com/pothosware/SoapySDR"
LIME_URL="https://github.com/myriadrf/LimeSuite"
GR_LIME_URL="https://github.com/myriadrf/gr-limesdr"
GR_OSMOSDR_URL="https://github.com/osmocom/gr-osmosdr"
GR_SOAPY_URL="https://github.com/pothosware/SoapyOsmo"
LIBOSMOCORE_URL="https://github.com/osmocom/libosmocore"

# get a know working version or commit
if [ "$GRC_38" = true ]; then
	# there is currently no version of gr-osmosdr from
	# the original authors that works with gnuradio 3.8
	# this specific commit has been tested and works
	SOAPY_REF="soapy-sdr-0.7.2"
	LIME_REF="v20.01.0"
	GR_LIME_REF="v3.0.1"
	GR_OSMOSDR_REF="v0.1.4"
	GR_SOAPY_REF="soapy-osmo-0.2.5"
	LIBOSMOCORE_REF="1.3.1"
else
	SOAPY_REF="soapy-sdr-0.7.2" # 0.6.1?
	LIME_REF="v20.01.0"
	GR_LIME_REF="v2.0.0"
	GR_OSMOSDR_REF="v0.1.4"
	GR_SOAPY_REF="soapy-osmo-0.2.5"
	LIBOSMOCORE_REF="0.12.1"
fi

# get and build the code for soapy
cd $SDR_SRC_DIR
clone_and_build $SOAPY_URL $SOAPY_REF user

# get and build code for LimeSuite
cd $SDR_SRC_DIR
clone_and_build $LIME_URL $LIME_REF user "-DCMAKE_PREFIX_PATH=$SDR_TARGET_DIR"

# get and build code for gr-limesdr
cd $SDR_SRC_DIR
clone_and_build $GR_LIME_URL $GR_LIME_REF user


# copy rules file unless it's already there
if [ ! -f /etc/udev/rules.d/64-limesuite.rules ]; then
	sudo cp $UDEV_RULES_PATH/64-limesuite.rules /etc/udev/rules.d/
	sudo udevadm control --reload-rules
fi

