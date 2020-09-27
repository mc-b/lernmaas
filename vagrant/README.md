Vagrant
=======

Vagrant ist eine Ruby-Anwendung (open-source) zum Erstellen und Verwalten von virtuellen Maschinen (VMs).

Die Ruby-Anwendung dient als Wrapper (engl. Verpackung, Umschlag) zwischen Virtualisierungssoftware wie VirtualBox, VMware und Hyper-V und Software-Konfiguration-Management-Anwendungen bzw. Systemkonfigurationswerkzeugen wie Chef, Saltstack und Puppet.

Diese Umgebung dient dazu, alle definierten Umgebungen aus [config.yaml](../config.yaml) lokal auf dem PC zu starten.

### Quick Start

Dazu wird ein normaler PC mit min. 8 GB RAM und 40 GB freier HD benötigt. Die Installation geht von einem Windows 10 PC aus. Auf Linux/Mac entfällt Git/Bash bzw. wird nur Git benötigt. 

Installiert [Git/Bash](https://git-scm.com/downloads), [Vagrant](https://www.vagrantup.com/) und [VirtualBox](https://www.virtualbox.org/).

Startet, einmalig, die Git/Bash Console, clont die lernmaas Umgebung und installiert benötigte Vagrant Plug-ins.

    git clone https://github.com/mc-b/lernmaas
    cd lernmaas
    vagrant plugin install vagrant-disksize
    
Dann ist pro VM das Shellscripts [createvm](createvm) auszuführen. Dieses erstellt ein Verzeichnis mit dem Modulnamen und darin ein Vagrantfile.
Einstellungen, wie RAM, Host-IP (hinter `-` im Namen), werden von [config.yaml](../config.yaml) geholt. Die VM und anschliessend der Browser gestartet. 

Beispiel:
    
    ./createvm m122-02




