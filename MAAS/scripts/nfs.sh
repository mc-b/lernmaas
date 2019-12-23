#!/bin/bash
#   
#   Installiert nfs und mountet Server Folders
#
SERVER_IP=$(sudo cat /var/lib/cloud/instance/datasource | cut -d: -f3 | cut -d/ -f3)
# SERVER_IP=192.168.2.10

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

# update /etc/fstab for reboots
cat <<%EOF% | sudo tee -a /etc/fstab
${SERVER_IP}:/data/config               /home/ubuntu/config     nfs defaults    0 10
${SERVER_IP}:/data/templates            /home/ubuntu/templates  nfs defaults    0 11
${SERVER_IP}:/data/storage/$(hostname)  /home/ubuntu/data       nfs defaults    0 12
%EOF%
