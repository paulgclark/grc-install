# This file contains common functions shared by many of the 
# install scripts
#
# This script assumes certain BASH variables will be defined

# this function clones and builds code from a cmake-style git repo
function clone_and_build() {
        git_repo_url=$1
        release_commit=$2 # can be either a release or commit
	user_mode=$3      # calling script is sudo or user
        cmake_args=$4     # in addition to the prefix build
	prefix=$5         # defaults to $SDR_TARGET_DIR

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
