#!/bin/bash
#
#	Kubernetes Join Worker
#
sudo swapoff -a

HOST=$(hostname | cut -d- -f 1 | sed -e 's/worker/master/g')
NO=$(hostname | cut -d- -f 2)
HOSTNAME=${HOST}-${NO}

# Verzeichnis fuer Persistent Volume
if [ -d $HOME/data ]
then 
    sudo ln -s $HOME/data /data
else
    sudo mkdir /data
    sudo chown ubuntu:ubuntu /data
    sudo chmod 777 /data
fi

# loop bis Master bereit, Timeout 5 Minuten
for i in {1..150}
do
    if  [ -f /data/join-${HOSTNAME}.sh ]
    then
        sudo bash -x /data/join-${HOSTNAME}.sh
        break
    fi
    sleep 2
done
