#!/bin/bash
#
#   Kubernetes Master Installation
#
HOME=/home/ubuntu
sudo swapoff -a

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address  $(hostname -I | cut -d ' ' -f 1) 

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown ubuntu:ubuntu $HOME/.kube/config

# aus Kompatilitaet zur Vagrant Installation
sudo mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown -R ubuntu:ubuntu /home/vagrant

# this for loop waits until kubectl can access the api server that kubeadm has created
sleep 120

# Pods auf Master Node erlauben
sudo su - ubuntu -c "kubectl taint nodes --all node-role.kubernetes.io/master-"

# Internes Pods Netzwerk (mit: --iface enp0s8, weil vagrant bei Hostonly Adapters gleiche IP vergibt)
sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo su - ubuntu -c "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml"

# Install ingress bare metal, https://kubernetes.github.io/ingress-nginx/deploy/
sudo su - ubuntu -c "kubectl apply -f https://raw.githubusercontent.com/mc-b/lernkube/master/addons/ingress-mandatory.yaml"
sudo su - ubuntu -c "kubectl apply -f https://raw.githubusercontent.com/mc-b/lernkube/master/addons/service-nodeport.yaml"
