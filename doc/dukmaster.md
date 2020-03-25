# [Docker und Kubernetes – Übersicht und Einsatz ](https://www.digicomp.ch/trends/docker-trainings/docker-und-kubernetes-uebersicht-und-einsatz)

Zugriff auf den Server
----------------------

### User / Password

Der User ist `ubuntu`, dass Password steht in der Datei [/data/.ssh/passwd](/data/.ssh/passwd).

Einloggen mittels

    ssh ubuntu@[IP Adresse]

### SSH

Auf der Server kann mittels [ssh](https://wiki.ubuntuusers.de/SSH/) zugegriffen werden.

Der private SSH Key ist auf dem Installierten Server unter [/data/.ssh/id_rsa](/data/.ssh/id_rsa) zu finden. Downloaden und dann wie folgt auf den Server einloggen:

    ssh -i id_rsa ubuntu@[IP Adresse]
    
**Hinweis**: Windows User verwenden [Putty](https://www.putty.org/) und den [Putty Key /data/.ssh/id_rsa.ppk](/data/.ssh/id_rsa.ppk). 

### Kubernetes CLI

Nachdem der Zugriff via SSH eingerichtet wurde, kann die Kubernetes Konfigurationsdatei `.kube/config` vom Server auf den lokalen Notebook/PC kopiert werden.

    scp -i id_rsa ubuntu@[IP Adresse]:.kube/config .
    
**Hinweis**: Windows User können zum kopieren [WinSCP](https://winscp.net/eng/docs/lang:de) verwenden.

Anschliessend brauchen wir noch das `kubectl` CLI, dann können wir von der [Kubernetes Site](https://kubernetes.io/de/docs/tasks/tools/install-kubectl/#installation-der-kubectl-anwendung-mit-curl) downloaden.

Die Pods können dann wie folgt angezeigt werden:

    kubectl --kubeconfig config get pods --all-namespaces

### Dashboard

Für den Zugriff auf das Dashboard benötigen wir den Zugriffstoken des `admin` Users und müssen einen Port zum lokalen Notebook/PC weiterleiten.

Ausgabe des Token

    kubectl --kubeconfig config -n kubernetes-dashboard describe secret
    
Weiterleitung des API Ports von Kubernetes zum lokalen Notebook/PC

    kubectl --kubeconfig config proxy
    
Aufruf des Dashboards mittels [http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)            

Übungen
-------

### Docker

* [03-1 Funktionaler Überblick](:32188/notebooks/work/03-1-Docker.ipynb)
* [03-2 Einfaches Image-Management](:32188/notebooks/work/03-2-Docker.ipynb)
* [03-3 Betrieb und Management von Docker-Containern](:32188/notebooks/work/03-3-Docker.ipynb)
* [03-3 Dedizierte Docker Image-Stände bauen und verwalte](:32188/notebooks/work/03-4-Docker.ipynb)
* [04-1 Container Security](:32188/notebooks/work/04-1-ContainerSecurity.ipynb)
* [05-1 Insecure Registry](:32188/notebooks/work/05-1-Registry.ipynb)

### Kubernetes

* [09-1 kubectl-CLI und Basis Ressourcen](:32188/notebooks/work/09-1-kubectl.ipynb)
* [09-2 kubectl-CLI und Basis Ressourcen (YAML Variante)](:32188/notebooks/work/09-2-YAML.ipynb)
* [09-3 Verteilung / ReplicaSet](:32188/notebooks/work/09-3-ReplicaSet.ipynb)
* [09-4 Rolling Update](:32188/notebooks/work/09-4-Deployment.ipynb)
* [09-4 Blue/Green Deployments](:32188/notebooks/work/09-4-Deployment-BlueGreen.ipynb)
* [09-4 Canary Deploment](:32188/notebooks/work/09-4-Deployment-Canary.ipynb)
* [09-5 Persistent Volumes und Claims](:32188/notebooks/work/09-5-hostPath.ipynb)
* [09-6 Volume Sharing von Containern](:32188/notebooks/work/09-6-Volume.ipynb)
* [09-7 Secrets](:32188/notebooks/work/09-7-Secrets.ipynb)
* [09-8 ConfigMaps](:32188/notebooks/work/09-8-ConfigMap.ipynb)
* [09-9 Liveness-, Readiness- und Startup-Tests](:32188/notebooks/work/09-9-Tests.ipynb)
* [09-10 Init Container](:32188/notebooks/work/09-10-Init.ipynb)

Weitere Beispiele
-----------------

* [Internet der Dinge](https://github.com/mc-b/duk/iot)
* [OS Ticket](https://github.com/mc-b/duk/osticket)
* [MySQL und Adminer](https://github.com/mc-b/duk/mysql)
* [Compiler](https://github.com/mc-b/duk/compiler)
* [Big Data](https://github.com/mc-b/duk/bigdata)
* [Kafka - Messaging](https://github.com/mc-b/duk/kafka) 
* [Helm](https://github.com/mc-b/duk/helm)
* [RBAC-Autorisierung](https://github.com/mc-b/duk/rbac/)
* [DevOps Umgebung](https://github.com/mc-b/duk/devops)
* [Microservice Beispiele](https://github.com/mc-b/duk/misegr)
* [Interaktives Lernen mit Jupyter/BeakerX](https://github.com/mc-b/duk/jupyter)
* [Tests - ohne Beschreibung](https://github.com/mc-b/duk/test)
* [Docker Registry (insecure!)](https://github.com/mc-b/duk/registry/)
* [Service Mesh](https://github.com/mc-b/duk/istio/) mit [Istio](http://istio.io)
* [kubeless (Serverless)](https://github.com/mc-b/duk/kubeless/)