#!/bin/bash
#   
#   Installiert den Firewall um die verschiedenen Server voneinnander abzusichern
#
#   ACHTUNG: bei Aenderungen Port 6443 Kubernetes offnen lassen
#
sudo apt install -y ufw

SERVER_IP=$(sudo cat /var/lib/cloud/instance/datasource | cut -d: -f3 | cut -d/ -f3)

# MAAS Master darf alles
sudo ufw allow from ${SERVER_IP} to any port 22:32767 proto tcp
sudo ufw allow from ${SERVER_IP} to any port 22:32767 proto udp

# Lokale Netzwerke ab SSH bis Kubernetes ohne 32188 (Docker und Kubernetes CLI)
for NETWORK in 192.168.2.0/24 192.168.8.0/24 
do
    sudo ufw allow from ${NETWORK} to any port    22:32187 proto tcp
    sudo ufw allow from ${NETWORK} to any port 32189:32767 proto tcp
    sudo ufw allow from ${NETWORK} to any port    22:32187 proto udp
    sudo ufw allow from ${NETWORK} to any port 32189:32767 proto udp
done  

# WireGuard von SSH bis Kubernetes und WireGuard selber, ohne SSH!
export NO=$(hostname | cut -d- -f 2)
if [ -f "/home/ubuntu/config/wireguard/${NO}.conf" ]
then
    IP=$(dig +short $(cat config/wireguard/01.conf | grep Endpoint | cut -d= -f2 | cut -d: -f1 ))
    RANGE=$(cat config/wireguard/01.conf | grep AllowedIPs | cut -d= -f2)
    sudo ufw allow from ${IP}    to any port 51820:51899 proto udp
    sudo ufw allow from ${RANGE} to any port 22:32767 proto tcp
    sudo ufw allow from ${RANGE} to any port 22:32767 proto udp
fi

sudo ufw enable

