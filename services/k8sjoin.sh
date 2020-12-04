#!/bin/bash
#
#	Kubernetes Join Worker
#
HOST=$(hostname | cut -d- -f 1 | sed -e 's/worker/master/g')
NO=$(hostname | cut -d- -f 2)
HOSTNAME=${HOST}-${NO}

# loop bis Master bereit, Timeout 1ne Minute
for i in {1..30}
do
    if  [ -f /data/join-${HOSTNAME}.sh ]
    then
        sudo bash -x /data/join-${HOSTNAME}.sh
        break
    fi
    sleep 2
done

## Hinweis wie joinen, falls nicht geklappt

if [ -f /etc/kubernetes/kubelet.conf ]
then

    cat <<%EOF% | sudo tee README.md

### Kubernetes Worker Node

    Worker Node von Kubernetes ${HOSTNAME} Master
  
%EOF%
else

    cat <<%EOF% | sudo tee README.md

### Kubernetes Worker Node

Um die Worker Node mit dem Master zu verbinden, ist auf dem Master folgender Befehl zu starten:
    
    sudo kubeadm token create --print-join-command
    
Dieser gibt den Befehl aus, der auf jedem Worker Node zu starten ist. 
  
%EOF%

done

bash -x helper/intro
