#!/bin/bash
#
#	Kubernetes Basis Installation
#
VERSION=1.17.0-00

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/Kubernetes.list
sudo apt-get -q 2 update
sudo apt-get install -q 2 -y kubelet=${VERSION} kubeadm=${VERSION}
