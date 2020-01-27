#!/bin/bash
#
#   OpenShift Installation
#
#

cd $HOME

wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
tar xvzf openshift*
cd openshift

sudo mv oc kubectl /usr/local/bin

# Unsichere Registry von OpenShift in Docker zulassen
cat << EOF | sudo tee /etc/docker/daemon.json 
{
     "insecure-registries" : [ "172.30.0.0/16" ]
}
EOF
sudo systemctl restart docker

# OpenShift starten (Hostname = WireGuard IP)
oc cluster up --public-hostname=$(hostname -I | cut -d" " -f2)