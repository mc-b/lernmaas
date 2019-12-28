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

if  [ -d /home/ubuntu/templates/cr-cache/${HOST} ]
then
    for image in /home/ubuntu/templates/cr-cache/${HOST}/*.tar
    do
        sudo docker load -i ${image}
    done
fi

sudo docker image ls