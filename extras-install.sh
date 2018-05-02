# after installation completes, you'll be prompted to log in
# you'll then be able to control selective sync and startup behavior
# from the Dropbox icon in the upper right system tray 
sudo apt install -y nautilus-dropbox

# stock vi has some issues; fix them with vim
sudo apt install -y vim

# add standard git ignore file
cp ./misc/gitignore_global ~/.gitignore_global
# NOTE: you may want to copy/create your own .gitconfig file as well

# install pycharm
sudo snap install pycharm-community --classic

# install audacity
sudo apt install -y audacity

# install gr-limesdr
sudo apt install -y cmake
sudo apt install


