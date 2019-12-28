#!/bin/bash
#   
#   Installiert Docker-CE
#

####
# Installation Docker 
sudo apt install -y docker.io
sudo usermod -aG docker ubuntu 

####
# Abhandlung Container Cache

# Worker Node - Hostname vom Master verwenden
HOST=$(hostname | cut -d- -f 1 | sed -e 's/worker/master/g')

# Kubernetes Images 
if  [ -d /home/ubuntu/templates/cr-cache/k8s ]
then
    for image in /home/ubuntu/templates/cr-cache/k8s/*.tar
    do
        sudo docker load -i ${image}
    done
fi

# Modul spezifische Images
if  [ -d /home/ubuntu/templates/cr-cache/${HOST} ]
then
    for image in /home/ubuntu/templates/cr-cache/${HOST}/*.tar
    do
        sudo docker load -i ${image}
    done
fi

sudo docker image ls