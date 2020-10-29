Juju
====

[![](https://img.youtube.com/vi/KT1-ozwDMho/0.jpg)](https://www.youtube.com/watch?v=KT1-ozwDMho)

- - -

[Juju](https://jaas.ai/) ist ein Open Source-Tool zur Modellierung von Anwendungen, das von Canonical Ltd. Entwickelt wurde . 

Juju konzentriert sich auf die Reduzierung des Betriebsaufwands heutiger Software durch die schnelle Bereitstellung, Konfiguration, Skalierung, Integration und Ausführung von Betriebsaufgaben für eine große Auswahl an öffentlichen und privaten Cloud-Diensten sowie für Bare-Metal-Server und lokale Container-basierte Bereitstellungen.

Dazu gibt es bei Juju "Charms" und "Bundles" wo festlegen, was installiert werden soll. Vorgefertige "Charms" und "Bundles" finden wir im [Juju Store](https://jaas.ai/store).

### Installation

    sudo snap install juju --classic

MAAS Cloud hinzufügen, als API-Endpoint den URL des MAAS UI angeben, z.B. `http://172.16.17.13:5240/MAAS` angeben.
    
    juju add-cloud
    
Anschliessend sind Credential (API-Key des Users `ubuntu` in MAAS) und der Juju Umgebung zu bootstrapen. Die entsprechenden Befehle werden angezeigt.

Nach dem Aufsetzen kann der URL des Juju UIs und dessen Password angezeigt werden:

    juju gui
    
**Tip**: Name des Controllers als Umgebungsvariable `CONTROLLER` speichern.    


### Juju und virtuelle Maschinen

Nachdem der Juju Controller im MAAS installiert ist, können wir anhand der Vorlagen im [Juju Store](https://jaas.ai/store) neue VMs erstellen.

Juju sucht sich dabei automatisch einen freien KVM Server, erstellt einen neue VM und installiert die entsprechende Software.

**Beispiel Apache Web Server**

    juju add-model web
    juju deploy cs:apache2-35
    
Wie der Apache Web Server zu installieren ist steht im [Charm](https://jaas.ai/apache2/35).

Wenn wir den Web Server nicht mehr benötigen, können wir ihn wie folgt wieder löschen:

    juju destroy-model web
  
### Juju und Kubernetes

**Kubernetes mit Juju aufsetzen**

    juju add-model k8score
    juju deploy https://jaas.ai/kubernetes-core
    
Um mit dem Kubernetes Cluster zu kommunizieren brauchen wir die Konfigurationsdatei .kube/config. Diese können wir uns mittels juju vom dem Kubernetes Master (VM) in die lokale Umgebung kopieren:
     
    mkdir -p ~/.kube
    juju scp kubernetes-master/0:config ~/.kube/config
    snap install kubectl --classic
    kubectl cluster-info
    
Für das Einrichten einer Persistenten Ablage (PersistentVolume) siehe [nfs](https://github.com/mc-b/lernkube/tree/master/nfs).    

Um ausgesuchte Services auf dem Kubernetes Cluster auszurollen, siehe Projekt [duk](https://github.com/mc-b/duk#weitere-beispiele). Damit diese funktionieren sind ggf. die `hostPath` Einträge aus dem YAML Datei zu entfernen und weitere Software in den Container zu installieren, siehe z.B. [Jupyter](https://github.com/mc-b/duk/tree/master/jupyter).

**Zugriff auf Kubernetes Master mittels WireGuard**

    juju ssh <ip k8s master>
    sudo apt-get install -y wireguard
    
[Konfiguration Wireguard mittels /etc/wireguard/wg0.conf](https://github.com/mc-b/lernmaas/blob/master/doc/MAAS/GatewayClient.md#vpn)

    sudo systemctl enable wg-quick@wg0.service
    sudo systemctl start wg-quick@wg0.service
    exit
    
Auf dem Rack Server

    juju config kubernetes-master extra_sans=<WireGuard IP Adresse>
    
Datei `~/.kube/config` editieren und lokale IP-Adresse durch WireGuard IP Adresse ersetzen.        

### Links

* [Example Adding a K8S Cloud and Model](https://discourse.jujucharms.com/t/tutorial-2-6-2-example-adding-a-k8s-cloud-and-model/1484) und [Installing Kubernetes with CDK and using auto-configured storage](https://jaas.ai/docs/k8s-cdk-autostorage-tutorial)
* [kubernetes-core](https://jaas.ai/kubernetes-core)
