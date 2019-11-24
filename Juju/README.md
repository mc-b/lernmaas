Juju
====

### Installation

    sudo snap install juju --classic

MAAS Cloud hinzufügen, als API-Endpoint den URL des MAAS UI angeben, z.B. `http://172.16.17.13:5240/MAAS` angeben.
    
    juju add-cloud
    
Anschliessend sind Credential (API-Key des Users `ubuntu` in MAAS) und der Juju Umgebung zu bootstrapen. Die entsprechenden Befehle werden angezeigt.

Nach dem Aufsetzen kann der URL des Juju UIs und dessen Password angezeigt werden:

    juju gui
    
**Tip**: Name des Controllers als Umgebungsvariable `CONTROLLER` speichern.    
    
### Juju und virtuelle Maschinen

Wir wollen 8 VMs mit dem Apache Web Server aufsetzen. Dafür ist wie folgt vorzugehen:

* Aufruf des [MAAS UI](http://localhost:5240/MAAS) und anlegen des Pools `web`.
* Anlegen der VMs, dazu brauchen wir zuerst die Ids der Pods (HW mit KVM) und die des Pools

    POD=$(maas $PROFILE pods read | jq '.[] | select (.name=="<name>") | .id')
    POOL=$(maas ${PROFILE} resource-pools read | jq '.[] | select (.name=="web") | .id')
    for x in {01..08} ; do maas ${PROFILE} pod compose ${POD} memory=1024 cpu=1 pool=${POOL} hostname=web-${x} ; done       
 
Das Ergebnis sind 8 neue VMs im ausgeschalteten Zustand ohne Betriebssystem mit dem Status `Ready`. Diese sind mit dem Tag `web` zu versehen (weil juju keine constraints resource-pool kennt).
 
Die Installation übernimmt Juju. Dazu arbeitet Juju mit Models, ähnlich Workspaces.  

Zuerst legen wir ein neues Model an, wechseln in dieses und führen dort unsere Arbeiten aus:

    juju add-model web
    juju switch ${CONTROLLER}:web
    juju list-models
    
    juju list-machines
    juju deploy apache2 -n 8  --constraints tags=web    
    
Die so erstellen VMs können wir uns ansehen

    juju list-machines
        
  
### Juju und Kubernetes

Zuerst brauchen wir eine Kubernetes Umgebung.

Diese lässt sich einfach über das Juju GUI einrichten, z.B. die [kubernetes-core](https://jaas.ai/kubernetes-core) Umgebung.

**Tips**
* Die Maschinen zuerst im [MAAS UI](http://localhost:5240/MAAS) einrichten und mit `juju` taggen. Beim Einrichten drauf achten, dass die Maschinen über mehrere (KVM-)Pods verteilt sind.
* Mehr Worker Nodes können über das Juju GUI im Tab `machines` durch drücken von `+` und hinzufügen von `kubernetes-worker` units erstellt werden. Bei den Workern ist auf genügend CPUs (4), Memory (4096) und Storage (16G) zu achten.

Nach der Installation benötigen wir die die Konfigurationsdatei von Kubernetes.

Die Konfigurationsdatei mit Server Zertifikat steht im Verzeichnis `/home/ubuntu` des Kubernetes Masters. Diese muss auf den aktuellen Server kopiert werden:

    mkdir -p ~/.kube
    juju scp kubernetes-master/0:config ~/.kube/config
    snap install kubectl --classic
    kubectl cluster-info

**Ab hier nicht getestet**

Anschliessend müssen wir das Juju GUI in Kubernetes bekanntmachen. Dazu muss zuerst ein StorageClass eingerichtet werden und anschliessend juju mit Kubernetes verbunden werden.

    git clone https://github.com/mc-b/lernkube
    kubectl apply -f lernkube/data
    
Die StorageClass ist vorhanden nun können wir juju mit Kubernetes verbinden:
    
    juju add-k8s --local juju-cluster --storage=local-storage --cloud=localhost
    
    juju add-model --local juju-model juju-cluster
    
    juju bootstrap --local juju-cluster
    
Der zweite Befehl erzeugt einen Pod und einen Service mit dem Juju Gui. Der Port ist aber leider nicht im LoadBalancer sichtbar, weshalb wir diesen weiterleiten müssen:

    kubectl --kubeconfig .kube/config -n controller-juju-cluster port-forward service/controller-service 17070
          
Siehe auch 
* [Example Adding a K8S Cloud and Model](https://discourse.jujucharms.com/t/tutorial-2-6-2-example-adding-a-k8s-cloud-and-model/1484) und [Installing Kubernetes with CDK and using auto-configured storage](https://jaas.ai/docs/k8s-cdk-autostorage-tutorial)
* [kubernetes-core](https://jaas.ai/kubernetes-core)