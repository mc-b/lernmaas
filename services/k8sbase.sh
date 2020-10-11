#!/bin/bash
#
#	Kubernetes Basis Installation
#
VERSION=1.19.1-00

# Deaktiviert permanent den SWAP Speicher - darf bei Kubernetes nicht aktiviert sein!

sudo swapoff -a
cat /etc/fstab | grep -v swap.img | sudo tee /etc/fstab
sudo rm -f /swap.img

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/Kubernetes.list
sudo apt-get -q 2 update
sudo apt-get install -q 2 -y kubelet=${VERSION} kubeadm=${VERSION}

# Bug vagrant, @see https://linuxacademy.com/community/posts/show/topic/29447-pod-is-not-found-eventhough-pod-status-is-up-and-running-why
if  [[ "$(hostname)" =~ "worker" ]]
then
    cat <<%EOF% | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
Environment="KUBELET_EXTRA_ARGS=--node-ip=$(hostname -I | cut '-d ' -f2)"
%EOF%

    sudo systemctl daemon-reload
    sudo systemctl restart kubelet

fi