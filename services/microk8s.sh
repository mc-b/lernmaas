#!/bin/bash
#   
#   Installiert die Microk8s Umgebung
#

# Basic Installation

sudo snap install microk8s --classic --channel=1.19
sudo usermod -a -G microk8s ubuntu
sudo chown -f -R ubuntu ~/.kube
sudo echo 'alias kubectl="microk8s kubectl"' >>/home/ubuntu/.bashrc 
sudo microk8s enable dns storage

# Intro

cat <<%EOF% | sudo tee README.md

### microk8s Kubernetes

[![](https://img.youtube.com/vi/v9KI2BAF5QU/0.jpg)](https://www.youtube.com/watch?v=v9KI2BAF5QU)

What is MicroK8s?
- - -

Weitere Informationen: [https://microk8s.io/](https://microk8s.io/)
  
%EOF%

bash -x helper/intro