#!/bin/bash
#
#   SSH Key hinterlegen bzw. generieren
#
sudo apt install -y pwgen

# eigenen SSH Key fuer VM generieren und Privaten Schluessel im Data Verzeichnis verfuegbar machen
if  [ "$1" == "generate" ]
then
    cd $HOME
    ssh-keygen -t rsa -f .ssh/id_rsa -b 4096 -P ''
    cat .ssh/id_rsa.pub >>.ssh/authorized_keys
    mkdir -p data/.ssh
    chmod 755 data/.ssh
    cp .ssh/id_rsa data/.ssh
    
    # Password auch setzen um einloggen ohne Zertifikat zu ermoeglichen 
    pwgen 8 1 >.ssh/passwd
    sudo chpasswd <<<ubuntu:$(cat .ssh/passwd)
    sudo sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo systemctl restart sshd

    # nach Zugriff data/.ssh wegloeschen
    cp .ssh/id_rsa .ssh/id_rsa.ppk .ssh/passwd data/.ssh/
    chmod g+r,o+r data/.ssh/*
fi   

# Vorbereiteten Key fuer diese Umgebung verwenden, zuerst hostname dann HOST.pub pruefen
if  [ "$1" == "use" ]
then
    cd $HOME
    if [ -f "/home/ubuntu/config/ssh/$(hostname).pub" ]
    then
        cat /home/ubuntu/config/ssh/$(hostname).pub >>.ssh/authorized_keys
    elif  [ -f "/home/ubuntu/config/ssh/${HOST}.pub" ]
    then
        cat "/home/ubuntu/config/ssh/${HOST}.pub" >>.ssh/authorized_keys
    fi
fi

# ssh Tunnel erlaubt?
cd $HOME
if [ -f "/home/ubuntu/config/ssh/${HOST}_tunnel" ]
then
    cp "/home/ubuntu/config/ssh/${HOST}_tunnel" .ssh/ssh_tunnel
    chmod 600 .ssh/ssh_tunnel
fi    
    
            
        