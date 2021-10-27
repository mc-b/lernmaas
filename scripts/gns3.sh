#!/bin/bash
#
#   Installation GNS3 Server und GUI
#
#   Muss zusammen mit gnome-desktop.sh verwendet werden

sudo add-apt-repository ppa:gns3/ppa -y
sudo apt-update
sudo apt install gns3-gui gns3-server gns3-gui -y
