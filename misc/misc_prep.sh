#!/bin/bash

# prevent screen from automatically locking
gsettings set org.gnome.desktop.screensaver lock-enabled false
# increase the delay time before the screen blanks (arg is in seconds)
gsettings set org.gnome.desktop.session idle-delay $((15*60))

sudo apt install vim

