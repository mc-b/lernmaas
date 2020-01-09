Installation MAAS
-----------------

Für eine detailierte Installation, siehe [MAAS](MAAS/) oder [Bare Metal to Kubernetes-as-a-Service - Part 1](https://www.2stacks.net/blog/bare-metal-to-kubernetes-part-1/).

### Master
 
[Ubuntu](https://ubuntu.com/download/desktop) als Desktop aufsetzen. Dabei genügt die minimale Version. 

Fixe IP-Adresse vergeben, z.B. über Einstellungen, Software Update durchführen und MAAS Installieren

    sudo add-apt-repository ppa:maas/stable -y  
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y maas jq markdown nmap traceroute wsmancli git curl wget

MAAS Admin User erstellen und Profilnamen `ubuntu` als Umgebungvariable setzen

    sudo maas init --admin-username ubuntu --admin-password password --admin-email xx.yy@zz.ch
    cat <<%EOF% >>$HOME/.bashrc
    PROFILE=ubuntu
    %EOF%
    
SSH-Key erstellen, den brauchen wir nachher

    ssh-keygen    
    
IP4 Forward permanent einrichten:

    sysctl -w  net.ipv4.ip_forward=1
    sudo vi /etc/sysctl.conf

**Hinweis** auf den Installierten KVM Server kann IP4 Forward deaktiviert werden, bringt Geschwindigkeit.

Browser starten und UI von MAAS aufrufen [http://localhost:5240](http://localhost:5240)

* SSH-Key, von vorher `cat ~/.ssh/id_rsa.pub`  eintragen
* Den MAAS Master (braucht es für die interne Namensauflösung) und die bekannten DNS Server eintragen
* Bei Subnets DHCP Server aktivieren auf z.B. 172.16.17.x, Gateway IP: 172.16.17.1 und DNS Server eintragen

**Server frisch starten, ansonsten werden die Änderungen nicht übernommen.**

* Images syncen  

**Tip**: vino auf dem Master installieren, damit ist der GUI via VNC erreichbar.

#### Gemeinsame Datenablage

Auf dem MAAS Master sollte eine gemeinsame Datenablage eingerichtet werden. Dann sind die Dateien die auf den VMs im $HOME/data Verzeichnis gespeichert werden, nach dem Löschen der VM noch auf dem MAAS Master vorhanden.

Ausserdem können auf der gemeinsamen Datenablage WireGuard `/data/config/wireguard` Zugriffsdateien und gecachte Container Images `/data/templates/cr-cache` abgelegt werden.

Als gemeinsame Datenablage wird NFS verwendet.

Installation NFS

    sudo apt-get update
    sudo apt install -y nfs-kernel-server
    
Shared Folder anlegen

    sudo mkdir -p /data /data/storage /data/config /data/templates /data/config/wireguard /data/config/ssh /data/templates/cr-cache
    sudo chown -R ubuntu:ubuntu /data
    sudo chmod 777 /data/storage
    
Zugriff für Subnetze (192.168.2.0 = eigenes Subnets, 10.244.0.0 = Kubernetes/flannel) freischalten
    
    cat <<%EOF% | sudo tee /etc/exports
    # /etc/exports: the access control list for filesystems which may be exported
    #               to NFS clients.  See exports(5).
    # Storage RW
    /data/storage 172.18.0/16(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=1000)
    /data/storage 10.244.0.0/16(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=1000)
    # Templates RO
    /data/templates 172.18.0/16(ro,sync,no_subtree_check)
    /data/templates 10.244.0.0/16(ro,sync,no_subtree_check)
    # Config RO
    /data/config 172.18.0/16(ro,sync,no_subtree_check)
    /data/config 10.244.0.0/16(ro,sync,no_subtree_check)
    %EOF%
     
    sudo exportfs -a
    sudo systemctl restart nfs-kernel-server
    
**Hinweis** nach erfolgter Installation jeweils einer auf Kubernetes basierten Umgebung lohnt es sich mittels `ccopy` die Container Images nach `/data/template/cr-cache/<Module>` zu exportieren. Dann müssen bei erneuter Installation nicht mehr alle Container Images über das Internet geholt werden, sondern nur aus dem internen Netz von `cr-cache`.      

#### Konfiguration

Für die automatische Installation von Software auf die VMs wird eine Kombination von [MAAS Preseed](Customising.md) und [Cloud Init](https://cloudinit.readthedocs.io/en/latest/) verwendet.

[MAAS Preseed](Customising.md) installiert dabei das Betriebssystem und führt u.a. Tests der Hardware durch. In diesem Arbeitsgang ist die eigentliche VMs nur gemountet und nicht gestartet!

[Cloud Init](https://cloudinit.readthedocs.io/en/latest/) ist ein Standard für die Initialisierung von VMs in der Cloud und wird u.a. von [Microsoft Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init) unterstützt. In diesem Arbeitsgang ist das Betriebssystem installiert und die VMs gestartet.

[lernmaas](https://github.com/mc-b/lernmaas) stellt eine Preseed Datei zur Verfügung, welche auf den MAAS Master kopiert werden muss. Diese Preseed Datei clont lernmaas und kopiert die Cloud Init Initialisierungsdatei [cloud.cfg.d/99_lernmaas.cfg](https://raw.githubusercontent.com/mc-b/lernmaas/master/cloud.cfg.d/99_lernmaas.cfg) auf die VM. Diese Datei, bzw. [services/cloud-init.sh](https://github.com/mc-b/lernmaas/blob/master/services/cloud-init.sh) installiert die eigentliche Software mittels dem Cloud-Init Prozess.

Preseed Datei und Hilfsscripts kopieren:
   
    git clone https://github.com/mc-b/lernmaas.git
    sudo cp lernmaas/preseeds/* /etc/maas/preseeds/
    sudo chmod +x lernmaas/helper/*
    sudo cp lernmaas/helper /usr/local/bin/

Ab der nächsten Installation einer VM mit Ubuntu wird jetzt [services/cloud-init.sh](https://github.com/mc-b/lernmaas/blob/master/services/cloud-init.sh) durchlaufen. 

Was installiert wird, bestimmt der Hostname der mit den Einträgen in [config.yaml](https://github.com/mc-b/lernmaas/blob/master/config.yaml) übereinstimmen muss. 

Als Alternative kann [Juju](../Juju/) verwendet werden. Damit lassen sich Kubernetes Cluster oder mehrere VMs mit Software, z.B. 24 VMs mit Apache, installieren.

### Worker Nodes   

Die Worker Nodes sind so zu Konfigurieren, dass sie via Netzwerk (PXE Boot) booten.

Anschliessend sind die zwei Installationsroutingen durchzuführen. 

- - -

[![](https://img.youtube.com/vi/jj1M-YyCgD4/0.jpg)](https://www.youtube.com/watch?v=jj1M-YyCgD4)

MAAS Enlistment 

---

[![](https://img.youtube.com/vi/k-9VHZg_qoo/0.jpg)](https://www.youtube.com/watch?v=k-9VHZg_qoo)

MAAS Commission 

- - -

Die neue Maschine anklicken und rechts oben mittels `Take action` -> Deploy die Software deployen (Ubuntu 18.04). Um auf der Maschine nachher virtuelle Maschinen erstellen zu können ist die Checkbox `Register as MAAS KVM host` zu aktivieren.

Nach der Installation steht die Maschine unter Pods zur Verfügung und es lassen sich neue virtuelle Maschinen darauf erstellen (Compose).

**Tips** 
* Normale PCs haben keine Unterstützung für [BMC](https://de.wikipedia.org/wiki/Baseboard_Management_Controller) deshalb muss der `Power type` auf `Manuel` eingestellt werden. Sollte das nicht funktionieren, zuerst bei `Configuration` unter `Power type`  IPMI und eine Pseudo IP und MAC Adresse eingeben und nachher auf `Manuel` wechseln.
* TBZ PCs haben integriertes Intel AMT. Power On, `Ctrl-P`, Default Password `admin` durch internes Ersetzen, IP Einstellungen vornehmen (ich verwende fixe IP ist mehr Aufwand aber nachher einfacher und **TCP Aktivieren**. Probieren mit `http://IP-Adresse:16992`. Vorsicht das AMT UI verwendet fix den US Tastaturlayout.
* PCs mittels `Lock` vor unbeabsichtigtem Ändern schützen.
  
## Links

* [Bare Metal to Kubernetes-as-a-Service - Part 1](https://www.2stacks.net/blog/bare-metal-to-kubernetes-part-1/)
* [MAAS Blog Übersicht](https://ubuntu.com/blog/tag/maas)
