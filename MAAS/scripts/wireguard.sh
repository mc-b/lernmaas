#!/bin/bash
#
#   Installiert WireGuard
#

sudo add-apt-repository -y ppa:wireguard/wireguard
sudo apt-get update
sudo apt-get install -y wireguard
sudo chmod 750 /etc/wireguard

# hostname-xx-y: xx = gleich Konfigurationsdatei WireGuard
export NO=$(hostname | cut -d- -f 2)

# Aktivierung nur wenn Konfigurationsdatei vorhanden ist
if [ -f "/home/ubuntu/config/wireguard/${NO}.conf" ]
then

    sudo cp /home/ubuntu/config/wireguard/${NO}.conf /etc/wireguard/wg0.conf

    sudo systemctl enable wg-quick@wg0.service
    sudo systemctl start wg-quick@wg0.service
    
fi    