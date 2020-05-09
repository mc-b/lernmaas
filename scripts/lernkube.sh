#!/bin/bash
#
#   Stellt die Scripts aus dem Projekt lernkube unter /usr/local/bin zur Verfuegung.
#

git clone https://github.com/mc-b/lernkube

sudo cp lernkube/bin/* /usr/local/bin/
sudo chmod +x /usr/local/bin/*