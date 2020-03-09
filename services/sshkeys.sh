#!/bin/bash
#
#   SSH Key hinterlegen bzw. generieren
#

# Putty Key Software
sudo apt install -y putty-tools unix2dos

# eigenen SSH Key fuer VM generieren und Privaten Schluessel im Data Verzeichnis verfuegbar machen
if  [ "$1" == "generate" ]
then
    cd $HOME
    ssh-keygen -t rsa -f .ssh/id_rsa -b 4096 -P ''
    cat .ssh/id_rsa.pub >>.ssh/authorized_keys
    mkdir -p data/.ssh
    chmod 700 data/.ssh
    cp .ssh/id_rsa data/.ssh
    puttygen .ssh/id_rsa -o .ssh/id_rsa.ppk
    unix2dos .ssh/id_rsa.ppk
    cp .ssh/id_rsa .ssh/id_rsa.ppk data/.ssh/
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
    
            
        