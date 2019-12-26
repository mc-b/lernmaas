#!/bin/bash
#   
#   Installiert den Firewall um die verschiedenen Server voneinnander abzusichern
#
sudo apt install -y ufw

SERVER_IP=$(sudo cat /var/lib/cloud/instance/datasource | cut -d: -f3 | cut -d/ -f3)

# MAAS Master darf alles
sudo ufw allow from ${SERVER_IP} to any port 22:32767 proto tcp
sudo ufw allow from ${SERVER_IP} to any port 22:32767 proto udp

# Lokales Netz nur Web Server und Kubernetes
sudo ufw allow from 192.168.2.0/24 to any port 80
sudo ufw allow from 192.168.2.0/24 to any port 30000:32767 proto tcp
sudo ufw allow from 192.168.2.0/24 to any port 30000:32767 proto udp

# WireGuard nur Web Server und Kubernetes
sudo ufw allow from 192.168.12.0/24 to any port 80
sudo ufw allow from 192.168.12.0/24 to any port 30000:32767 proto tcp
sudo ufw allow from 192.168.12.0/24 to any port 30000:32767 proto udp

sudo ufw enable

