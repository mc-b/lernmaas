#!/bin/bash
#   
#   Installiert Rancher k3s
#

curl -sfL https://get.k3s.io | sh -

# ubuntu User als Admin zulassen
sudo mkdir -p /home/ubuntu/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube
sudo chmod 700 /home/ubuntu/.kube
sudo echo 'export KUBECONFIG=$HOME/.kube/config' >>/home/ubuntu/.bashrc 

# Persistent Volumes und Claims einrichten - Daten werden auf MAAS Server /data/storage/$(hostname) gespeichert

# Verzeichnis fuer Persistent Volume
if [ -d $HOME/data ]
then 
    sudo ln -s $HOME/data /data
else
    sudo mkdir /data
    sudo chown ubuntu:ubuntu /data
    sudo chmod 777 /data
fi 

sudo kubectl apply -f https://raw.githubusercontent.com/mc-b/lernkube/master/data/DataVolume.yaml
