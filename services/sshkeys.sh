#!/bin/bash
#
#   SSH Key hinterlegen bzw. generieren
#

# eigenen SSH Key fuer VM generieren und Privaten Schluessel im Data Verzeichnis verfuegbar machen
if  [ "$1" == "generate" ]
then
    cd $HOME
    ssh-keygen -t rsa -f .ssh/id_rsa -b 4096 -P ''
    cat .ssh/id_rsa.pub >>.ssh/authorized_keys
    mkdir -p data/.ssh
    chmod 700 data/.ssh
    cp .ssh/id_rsa data/.ssh
fi    