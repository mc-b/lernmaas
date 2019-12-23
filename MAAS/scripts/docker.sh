#!/bin/bash
#   
#   Installiert Docker-CE
#

set -o xtrace

sudo apt install -y docker.io
sudo usermod -aG docker ubuntu 