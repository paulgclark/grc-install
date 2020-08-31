#!/bin/bash -x
# This script installs gr-sched from source. It is intended for
# execution AFTER the grc_from_source.sh script has been run and will
# install to the same target directory used for that process.
#
# This script should not be run with sudo:
# ./sched_from_source.sh
#

# first get a few common functions:
source ../common/common_functions.sh

# call function to get globals: script_path, script_name, user_name, cores
get_basic_info

# check if running script as root, else exit
exit_if_root

# check that the necessary environment vars in place, else exit
check_env_vars

repo_url="https://github.com/bastibl/gr-sched"
repo_ref="maint-3.8"

if [ "$GRC_38" = true ]; then
	echo "Detected GNU Radio 3.8.x - installing gr-sched..."
else
	echo "Detected GNU Radio 3.7.x - gr-sched required 3.8.x..."
	echo "Exiting..."
	exit 1
fi

clone_and_build $repo_url $repo_ref user \
	"-DGnuradio_DIR=$SDR_SDR_DIR/gnuradio/lib/cmake/gnuradio"

