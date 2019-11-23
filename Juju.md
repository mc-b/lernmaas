Juju
====

### Installation

    sudo -i
    snap install juju --classic

### MAAS Cloud hinzufügen, dabei ist den Anweisungen zu folgen als API-Endpoint den URL des MAAS UI angeben, z.B. `http://172.16.17.13:5240/MAAS`
    
    juju add-cloud
    
Crediential eintragen, wie ausgegeben. Dabei ist der API-Key des Users `ubuntu` anzugeben.    
    
    juju add-credential tbz5-01
    
Testen mit
    
    juju credentials
      
Neue VM mit 4 GB RAM und 16 GB HD erstellen mit dem Namen juju und taggen mit `juju`.    
      
    juju bootstrap --constraints tags=juju tbz5-01 juju
      
URL des Juju UIs und Password ausgeben: 
      
    juju gui
 
### Juju und Kubernetes

Zuerst brauchen wir eine Kubernetes Umgebung. Diese lässt sich einfach über das Juju GUI einrichten, z.B. die kubernetes-core Umgebung.

Die Konfigurationsdatei mit Server Zertifikat steht im Verzeichnis `/home/ubuntu` des Kubernetes Masters. Diese muss auf den aktuellen Server kopiert werden:

    mkdir -p ~/.kube
    scp ubuntu@<ip k8s master>:config .kube/config

Anschliessend müssen wir das Juju GUI in Kubernetes bekanntmachen. Dazu muss zuerst ein StorageClass eingerichtet werden und anschliessend juju mit Kubernetes verbunden werden.

    git clone https://github.com/mc-b/lernkube
    kubectl apply -f lernkube/data
    
Die StorageClass ist vorhanden nun können wir juju mit Kubernetes verbinden:
    
    juju add-k8s --local juju-cluster --storage=local-storage --cloud=localhost
    
    juju add-model --local juju-model juju-cluster
    
    juju bootstrap --local juju-cluster
    
Der zweite Befehl erzeugt einen Pod und einen Service mit dem Juju Gui. Der Port ist aber leider nicht im LoadBalancer sichtbar, weshalb wir diesen weiterleiten müssen:

    kubectl --kubeconfig .kube/config -n controller-juju-cluster port-forward service/controller-service 17070
          
Siehe auch [Example Adding a K8S Cloud and Model](https://discourse.jujucharms.com/t/tutorial-2-6-2-example-adding-a-k8s-cloud-and-model/1484) und [Installing Kubernetes with CDK and using auto-configured storage](https://jaas.ai/docs/k8s-cdk-autostorage-tutorial) 