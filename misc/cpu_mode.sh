#!/bin/bash
#
# This script sets the mode of all cpus to one of options:
#   performance:  useful if you want to make sure you are running at
#                 max CPU frequency (DEFAULT)
#   powersave:    see specs (likely your Intel system's startup mode)
#   userspace:    not supported by this script
#   ondemand:     not supported by this script
#   conservative: not supported by this script
#   schedutil:    not supported by this script
#   check:        not a cpu mode; reports current mode settings
#
# For more info, check out:
# https://www.kernel.org/doc/Documentation/cpu-freq/governors.txt

# The user should supply an argument specifying 
# get the number of processors (includes physical cores and threads)
CPU_COUNT=`nproc`

# if we don't get any command line argument, set to performance
if [ -z "$1" ]; then
	mode=performance
elif [ "$1" == performance ]; then
	mode=performance
elif [ "$1" == powersave ]; then
	mode=powersave
elif [ "$1" == userspace ]; then
	echo "Mode \"$1\" not supported by this script"
	exit 1
elif [ "$1" == ondemand ]; then
	echo "Mode \"$1\" not supported by this script"
	exit 1
elif [ "$1" == conservative ]; then
	echo "Mode \"$1\" not supported by this script"
	exit 1
elif [ "$1" == schedutil ]; then
	echo "Mode \"$1\" not supported by this script"
	exit 1
elif [ "$1" == check ]; then
	echo "Mode for each CPU:"
	cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
	exit 0
else
	echo "Invalid cpu mode selected. Must be one of:"
	echo "  - performance"
	echo "  - powersave"
	echo "  - check (no changes, reports current mode per cpu)"
	exit 1
fi

# set the governor mode for each processor
for ((i=0; i<$CPU_COUNT; i++)); do
	sudo cpufreq-set --cpu $i --governor $mode
done
