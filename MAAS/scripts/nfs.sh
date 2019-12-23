#!/bin/bash
#   
#   Installiert nfs und mountet Server Folders
#
# SERVER_IP=$(sudo cloud-init query v1.subplatform | cut -d: -f2 | cut -d/ -f3)
SERVER_IP=192.168.2.10

sudo apt install -y nfs-common

set -o xtrace

sudo mkdir -p /home/ubuntu/data /home/ubuntu/templates /home/ubuntu/config
sudo chown -R ubuntu:ubuntu /home/ubuntu/data /home/ubuntu/templates /home/ubuntu/config
sudo mount -t nfs ${SERVER_IP}:/data/config /home/ubuntu/config
sudo mount -t nfs ${SERVER_IP}:/data/templates /home/ubuntu/templates
sudo mount -t nfs ${SERVER_IP}:/data/storage /home/ubuntu/data
sudo mkdir -p /home/ubuntu/data/$(hostname) && chown ubuntu:ubuntu /home/ubuntu/data/$(hostname)
sudo umount /home/ubuntu/data
sudo mount -t nfs ${SERVER_IP}:/data/storage/$(hostname) /home/ubuntu/data
