#!/bin/bash
#
#   Kubernetes Rancher Installation
#
cd $HOME
git clone https://github.com/rancher/quickstart.git
cd quickstart/vagrant

sudo bash -x scripts/configure_rancher_server.sh admin v2.2.10 ""