#!/bin/bash
#   
#   Installiert die Microk8s Umgebung
#

# Basic Installation

sudo snap install microk8s --classic
sudo usermod -a -G microk8s ubuntu
sudo chown -f -R ubuntu ~/.kube
cat <<%EOF% | sudo tee /usr/local/bin/kubectl
#!/bin/bash
microk8s kubectl \$*
%EOF%
sudo chmod 755 /usr/local/bin/kubectl
# sudo echo 'alias kubectl="microk8s kubectl"' >>/home/ubuntu/.bashrc 
sudo microk8s enable dns storage

SERVER_IP=$(sudo cat /var/lib/cloud/instance/datasource | cut -d: -f3 | cut -d/ -f3)
MASTER=$(hostname | cut -d- -f 3,4)

# Master vorhanden?
if  [ "${SERVER_IP}" != "" ] && [ "${MASTER}" != "" ]
then

    # Master statt Worker Node mounten
    sudo umount /home/ubuntu/data
    sudo mount -t nfs ${SERVER_IP}:/data/storage/${MASTER} /home/ubuntu/data/
    sudo sed -i -e "s/$(hostname)/${MASTER}/g" /etc/fstab
    
    # loop bis Master bereit, Timeout zwei Minuten
    for i in {1..60}
    do
        if  [ -f /home/ubuntu/data/.ssh/id_rsa ]
        then
            # Password und ssh-key wie Master
            sudo chpasswd <<<ubuntu:$(cat /home/ubuntu/data/.ssh/passwd)
            cat /home/ubuntu/data/.ssh/id_rsa.pub >>/home/ubuntu/.ssh/authorized_keys
            # Node joinen
            sudo chmod 600 /home/ubuntu/data/.ssh/id_rsa
            echo $(ssh -i /home/ubuntu/data/.ssh/id_rsa -o StrictHostKeyChecking=no ${MASTER} microk8s add-node | awk 'NR==2 { print $0 }') >/tmp/join-${MASTER}
            sudo bash -x /tmp/join-${MASTER}
            sudo chmod 666 /home/ubuntu/data/.ssh/id_rsa
            break
        fi
        sleep 2
    done
fi

# Intro
    
cat <<%EOF% | sudo tee README.md
    
### microk8s Kubernetes

[![](https://img.youtube.com/vi/v9KI2BAF5QU/0.jpg)](https://www.youtube.com/watch?v=v9KI2BAF5QU)

What is MicroK8s?
- - -

Weitere Informationen: [https://microk8s.io/](https://microk8s.io/)
  
%EOF%

bash -x helper/intro
