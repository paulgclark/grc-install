# This file contains common functions shared by many of the 
# install scripts
#
# This script assumes certain BASH variables will be defined before
# it is executed. These variables are created during execution of
# the following script:
# https://github.com/paulgclark/grc-install/install_scripts/grc_from_source.sh

# this function acquires useful parameters
function get_basic_info() {
	# get name of script and its path
	script_path=$PWD
	script_name=${0##*/}

	# get username
	username=$SUDO_USER

	# number of cores to use for make
	cores=`nproc`
}

function exit_unless_root() {
	if [[ $EUID != 0 ]]; then
        	echo "You are attempting to run the script as user."
        	echo "Please run with sudo:"
        	echo "  sudo -E ./$script_name"
        	exit 1
	fi
}

function exit_if_root() {
	if [[ $EUID == 0 ]]; then
        	echo "You are attempting to run the script as root."
        	echo "Please do not run with sudo, but simply run:"
        	echo "  ./$script_name"
        	exit 1
	fi
}

function check_env_vars() {
	# there should also be an environment variable for the target and 
	# source paths; if there is not, quit
	if [[ -z "$SDR_TARGET_DIR" ]]; then
        	echo "ERROR: Environment variable \$SDR_TARGET_DIR not defined."
        	echo "       You should run ./grc_from_source.sh before running"
        	echo "       this script. If you've already done that, you may"
	       	echo "       need to open a new terminal and try this script"
	       	echo "       again."
        	exit 1
	fi

	if [[ -z "$SDR_SRC_DIR" ]]; then
        	echo "ERROR: Environment variable \$SDR_SRC_DIR not defined."
        	echo "       You should run ./grc_from_source.sh before running"
        	echo "       this script. If you've already done that, you may"
	       	echo "       need to open a new terminal and try this script"
	       	echo "       again."
        	exit 1
	fi

	if [[ -z "$GRC_38" ]]; then
        	echo "ERROR: Environment variable \$GRC_38 not defined."
        	echo "       You should run ./grc_from_source.sh before running"
        	echo "       this script. If you've already done that, you may"
	       	echo "       need to open a new terminal and try this script"
	       	echo "       again."
        	exit 1
	fi
}

# this function clones and builds code from a cmake-style git repo
function clone_and_build() {
        git_repo_url=$1
        release_commit=$2 # can be either a release or commit
	user_mode=$3      # calling script is sudo or user
        cmake_args=$4     # in addition to the prefix build
	prefix=$5         # defaults to $SDR_TARGET_DIR

	# change directories to current source dir
	cd $SDR_SRC_DIR

        # clone the repo and cd into new the directory 
	if [[ $user_mode == "user" ]]; then
		git clone --recursive $git_repo_url
	else
        	sudo -u "$username" git clone --recursive $git_repo_url
	fi

        cd `basename $git_repo_url`

	# if there is a specific release specified, check it out
	if [[ ! -z $2 ]]; then
		if [[  $user_mode == "user" ]]; then
        		git checkout $release_commit
        		git submodule update
		else
        		sudo -u "$username" git checkout $release_commit
        		sudo -u "$username" git submodule update
		fi
	fi

	# if there is a specific prefix called out, use it, otherwise
	# take it from the environment variable
	if [[ -z $5 ]]; then
		CMAKE_TARGET=$SDR_TARGET_DIR
	else
		CMAKE_TARGET=$5
	fi


        # build it
	if [[  $user_mode == "user" ]]; then
        	mkdir build
        	cd build
        	cmake -DCMAKE_INSTALL_PREFIX=$CMAKE_TARGET \
                                  	$cmake_args ../
        	make -j$CORES
        	make install
	else
        	sudo -u "$username" mkdir build
        	cd build
        	sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$CMAKE_TARGET \
                                  	$cmake_args ../
        	sudo -u "$username" make -j$CORES
        	sudo -u "$username" make install
	fi
}


# return the ubuntu version number
function get_ubuntu_version() {
	ubuntu_version_str=`hostnamectl | grep -i Ubuntu`
	regex_str='Ubuntu\s+([A-Za-z0-9]+)'
	if [[ ! "$ubuntu_version_str" =~ $regex_str ]]; then
		echo "ERROR: Not running Ubuntu. Install scripts will require"
		echo "       manual edits to run. Proceed at your own risk."
		exit 1
	else
		ubuntu_version=${BASH_REMATCH[1]}
		if [[ $ubuntu_version == "Focal" ]]; then
			ubuntu_version="20"
		fi
	fi
}
