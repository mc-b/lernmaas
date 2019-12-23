#!/bin/bash
#   
#   Installiert Rancher k3s
#

set -o xtrace

curl -sfL https://get.k3s.io | sh -
sudo mkdir -p /home/ubuntu/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube
sudo chmod 700 /home/ubuntu/.kube
sudo echo 'export KUBECONFIG=$HOME/.kube/config' >>/home/ubuntu/.bashrc 