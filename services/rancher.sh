#!/bin/bash
#
#   Kubernetes Rancher Installation
#
#   Installiert nur das UI um Cluster zu erstellen.
#   TODO: https://github.com/rancher/quickstart integrieren 
#
sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher