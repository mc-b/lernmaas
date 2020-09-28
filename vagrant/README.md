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
    cd lernmaas/vagrant
    vagrant plugin install vagrant-disksize
    
Dann ist pro VM das Shellscripts [createvm](createvm) auszuführen. Dieses erstellt ein Verzeichnis mit dem Modulnamen und darin ein Vagrantfile.

Einstellungen, wie RAM, CPU Cores, Size HD werden von [config.yaml](../config.yaml) geholt. Der Host Anteil für den Host-only Netzwerkadapter ist die Nummer hinter `-` im Namen. 

Anschliessend wird mittels `vagrant up` die VM gestartet, die Services installiert und am Schluss der Browser mit `http://<hostname>` gestartet. 

Beispiel:
    
    ./createvm m100-02

### FAQ

**Wie kann ich mittels SSH auf die VM zugreifen?**

    cd <hostname>
    ssh -i data/.ssh/id_rsa <hostname>

**Wieso werden die Anmeldeinformationen wie Passwörter und SSH Keys im Browser angezeigt?**

Für das erstemalige Anmelden in der VM werden diese Informationen benötigt. Dannach sind die Lehrenden angehalten das Password zu ändern und die Dateien, mit den Anmeldeinformationen, im Verzeichnis `/home/ubuntu/data/.ssh` zu löschen.

**Wo können Daten persistent abgelegt werden, damit sie nach dem Löschen der VM noch vorhanden sind?**

Das Verzeichnis `/home/ubuntu/data` wird auf dem lokalen PC als `<hostname>/data` gespeichert und ist auch nach dem Löschen der VM noch vorhanden.

**Wo können Konfigurationsdateien, welche beim Installieren der Services berücksichtigt werden, abgelegt werden?**

Im Verzeichnis `<hostname>/config` können Dateien wie SSH Keys, WireGuard Konfigurationen angelegt werden.

Der Inhalt dieses Verzeichnis entspricht `/data/config` auf dem Rack Server in der MAAS Umgebung.

**Wo können Vorlagen abgelegt werden?**

Im Verzeichnis `<hostname>/templates`. Das können vorbereitete Datenbanken, Exportierte Container Images (cr-cache) etc. abgelegt werden.

Der Inhalt dieses Verzeichnis entspricht `/data/templates` auf dem Rack Server in der MAAS Umgebung.
