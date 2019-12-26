#!/bin/bash
#   
#   Installiert Samba, smb Dienst und gibt das HOME Verzeichnis frei
#
sudo apt-get install -y samba

# /home/ubuntu/data allgemein Freigeben
cat <<%EOF% >>/etc/samba/smb.conf
[global]
workgroup = smb
security = user
map to guest = Bad Password

[public]
path = /home/ubuntu/data 
public = yes
writable = yes
comment = Datenverzeichnis
printable = no
guest ok = yes
%EOF%

sudo systemctl restart smbd
