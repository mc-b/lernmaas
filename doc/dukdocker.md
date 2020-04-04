# [Docker und Kubernetes – Übersicht und Einsatz ](https://www.digicomp.ch/trends/docker-trainings/docker-und-kubernetes-uebersicht-und-einsatz)

Server für manuelle Installation Kubernetes.

Docker ist bereits installiert.

### Zugriff auf den Server

**User / Password**

Der User ist `ubuntu`, dass Password steht in der Datei [/data/.ssh/passwd](/data/.ssh/passwd).

Einloggen mittels

    ssh ubuntu@[IP Adresse]

**SSH**

Auf der Server kann mittels [ssh](https://wiki.ubuntuusers.de/SSH/) zugegriffen werden.

Der private SSH Key ist auf dem Installierten Server unter [/data/.ssh/id_rsa](/data/.ssh/id_rsa) zu finden. Downloaden und dann wie folgt auf den Server einloggen:

    ssh -i id_rsa ubuntu@[IP Adresse]
    
**Hinweis**: Windows User verwenden [Putty](https://www.putty.org/) und den [Putty Key /data/.ssh/id_rsa.ppk](/data/.ssh/id_rsa.ppk). 