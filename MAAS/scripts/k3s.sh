#!/bin/bash
#   
#   Installiert Rancher k3s
#

set -o xtrace

curl -sfL https://get.k3s.io | sh -

# ubuntu User als Admin zulassen
sudo mkdir -p /home/ubuntu/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube
sudo chmod 700 /home/ubuntu/.kube
sudo echo 'export KUBECONFIG=$HOME/.kube/config' >>/home/ubuntu/.bashrc 

# Persistent Volumes und Claims einrichten - Daten werden auf MAAS Server /data/storage/$(hostname) gespeichert
sudo kubectl apply -f /opt/lernmaas/MAAS/data
