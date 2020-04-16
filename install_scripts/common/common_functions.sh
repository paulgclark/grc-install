# This file contains common functions shared by many of the 
# install scripts
#
# This script assumes certain BASH variables will be defined

# this function clones and builds code from a cmake-style git repo
function clone_and_build() {
        git_repo_url=$1
        release_commit=$2 # can be either a release or commit
        cmake_args=$3     # in addition to the prefix build
	prefix=$4         # defaults to $SDR_TARGET_DIR

        # clone the repo and cd into new the directory 
        sudo -u "$username" git clone --recursive $git_repo_url
        cd `basename $git_repo_url`

	# if there is a specific release specified, check it out
	if [[ ! -z $2 ]]; then
        	sudo -u "$username" git checkout $release_commit
        	sudo -u "$username" git submodule update
	fi

	# if there is a specific prefix called out, use it, otherwise
	# take it from the environment variable
	if [[ -z $4 ]]; then
		CMAKE_TARGET=$SDR_TARGET_DIR
	else
		CMAKE_TARGET=$4
	fi


        # build it
        sudo -u "$username" mkdir build
        cd build
        sudo -u "$username" cmake -DCMAKE_INSTALL_PREFIX=$CMAKE_TARGET \
                                  $cmake_args ../
        sudo -u "$username" make -j$CORES
        sudo -u "$username" make install
}


# return the ubuntu version number
function get_ubuntu_version() {
	ubuntu_version_str=`hostnamectl | grep -i Ubuntu`
	regex_str='Ubuntu\s+([0-9]+)\.'
	if [[ ! "$ubuntu_version_str" =~ $regex_str ]]; then
		echo "ERROR: Not running Ubuntu. Install scripts will require"
		echo "       manual edits to run. Proceed at your own risk."
		exit 1
	else
		ubuntu_version=${BASH_REMATCH[1]}
	fi
}
