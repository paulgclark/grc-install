#!/bin/bash
# Best practice is to create an install directory off your home, then 
# cloning the git repo as follows:
# cd
# mkdir install
# cd install
# git clone https://github.com/paulgclark/grc-install
# 
# NOTE: You should run one of the gnuradio installation scripts BEFORE
# you run this one. Recommended is grc_from_source.sh
#
# You should then run this script in place with the following commands:
# cd grc-install/install-scripts
# sudo ./grc_install_flabs_class.sh
# 
# If you run this script from another directory, you will break some
# relative path links and the install will fail.

# first get a few common functions:
source ./common/common_functions.sh

# call function to get globals: script_path, script_name, user_name, cores
get_basic_info

# check if running script as root, else exit
exit_unless_root

# check that the necessary environment vars in place, else exit
check_env_vars

# determine if we are running in developer mode
# or if we are running in deploy mode (read-only)
# check if arg been passed for this, else assume deploy mode
if [ -z "$1" ]; then
        deploy_mode=true
        echo "Installing Factoria Labs extras in read-only DEPLOY mode..."
elif [ "$1" == "deploy" ]; then
        deploy_mode=true
        echo "Installing Factoria Labs extras in read/write DEV mode..."
        echo "	NOTE: Must have the appropriate GitHub key for this to work"
elif [ "$1" == "dev" ]; then
        deploy_mode=false
        echo "Installing Factoria Labs extras in read-only DEPLOY mode..."
else
        echo "Invalid selection. Please enter one of these:"
        echo "  sudo -E ./$script_name "
        echo "  sudo -E ./$script_name deploy"
        echo "  sudo -E ./$script_name dev"
        exit 1
fi

VERSION_38="master"
VERSION_37="maint-3.7"
repo_url="https://github.com/paulgclark/gr-reveng"

# select the version of the code based on which gnuradio is installed
if [ "$GRC_38" = true ]; then
        repo_ref="$VERSION_38"
else
        repo_ref="$VERSION_37"
fi

# install custom blocks
sudo apt -y install cmake
sudo apt -y install swig

# get and build the code for gr-reveng
cd $SDR_SRC_DIR
clone_and_build $repo_url $repo_ref


# installing Python code for use in some exercises into the same src dir
cd $SDR_SRC_DIR 
if [ $deploy_mode == true ]
	sudo -u "$username" git clone https://github.com/paulgclark/rf_utils
	sudo -u "$username" echo "" >> ~/.bashrc
	sudo -u "$username" echo "################################" >> ~/.bashrc
	sudo -u "$username" echo "# Custom code for gnuradio class" >> ~/.bashrc
	sudo -u "$username" echo "export PYTHONPATH=\$PYTHONPATH:$SDR_SRC_DIR/rf_utilities"  >> ~/.bashrc
	sudo -u "$username" echo "" >> ~/.bashrc
	# install pycharm for classes 2-4
	sudo snap install pycharm-community --classic
else 
	# this won't work without GitHub key on machine
	sudo -u "$username" git clone https://github.com/paulgclark/flabs_utils
	sudo -u "$username" echo "" >> ~/.bashrc
	sudo -u "$username" echo "################################" >> ~/.bashrc
	sudo -u "$username" echo "# Custom code for gnuradio class" >> ~/.bashrc
	sudo -u "$username" echo "export PYTHONPATH=\$PYTHONPATH:$SDR_SRC_DIR/flabs_utils/flabs_utils"  >> ~/.bashrc
	sudo -u "$username" echo "" >> ~/.bashrc
fi

# other useful stuff
sudo apt install -y vim

