#!/bin/bash
#   
#   Installiert nfs und mountet Server Folders
#
SERVER_IP=$(sudo cat /var/lib/cloud/instance/datasource | cut -d: -f3 | cut -d/ -f3)
HOSTNAME=$(hostname)

sudo apt install -y nfs-common

# Worker Node - Hostname vom Master verwenden
if  [[ "$(hostname)" =~ "worker" ]]
then

    HOST=$(hostname | cut -d- -f 1 | sed -e 's/worker/master/g')
    NO=$(hostname | cut -d- -f 2)
    HOSTNAME=${HOST}-${NO}
fi

sudo mkdir -p /home/ubuntu/data /home/ubuntu/templates /home/ubuntu/config
sudo chown -R ubuntu:ubuntu /home/ubuntu/data /home/ubuntu/templates /home/ubuntu/config
sudo chmod 777 /home/ubuntu/data
sudo mount -t nfs ${SERVER_IP}:/data/config /home/ubuntu/config
sudo mount -t nfs ${SERVER_IP}:/data/templates /home/ubuntu/templates
sudo mount -t nfs ${SERVER_IP}:/data/storage /home/ubuntu/data

# remount data mit neuem Verzeichnis data/${HOSTNAME}
sudo mkdir -p /home/ubuntu/data/${HOSTNAME} && chown ubuntu:ubuntu /home/ubuntu/data/${HOSTNAME} && chmod 777 /home/ubuntu/data/${HOSTNAME}
sudo umount /home/ubuntu/data
sudo mount -t nfs ${SERVER_IP}:/data/storage/${HOSTNAME} /home/ubuntu/data

# CleanUp alte Join Dateien von Kubernetes
sudo rm -f /home/ubuntu/data/join-*.sh

# update /etc/fstab for reboots
cat <<%EOF% | sudo tee -a /etc/fstab
${SERVER_IP}:/data/config               /home/ubuntu/config     nfs defaults    0 10
${SERVER_IP}:/data/templates            /home/ubuntu/templates  nfs defaults    0 11
${SERVER_IP}:/data/storage/${HOSTNAME}  /home/ubuntu/data       nfs defaults    0 12
%EOF%
