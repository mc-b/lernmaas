#!/bin/bash
#
#	Kubernetes Basis Installation
#
VERSION=1.19.2-00

# Deaktiviert permanent den SWAP Speicher - darf bei Kubernetes nicht aktiviert sein!

sudo swapoff -a
cat /etc/fstab | grep -v swap.img | sudo tee /etc/fstab
sudo rm -f /swap.img

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/Kubernetes.list
sudo apt-get -q 2 update
sudo apt-get install -q 2 -y kubelet=${VERSION} kubeadm=${VERSION}

##########################
# Package Manager (HELM - Achtung bei Versionwechsel auch client.sh aendern).
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
