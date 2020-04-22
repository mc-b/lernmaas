Fragen und Antworten
====================

Erstellen/Installieren von Machines (VMs)
-----------------------------------------

**Mein Modul/Kurs ist noch nicht vorhanden, wie komme ich zu meinem Modul?**

* Machine (VM) anlegen mit eigenem Namen, Nummer laut Excel Sheet (siehe Tab IP-Adressen und WG-..) z.B. wie wid-21
    * AZ und Tag "wireguard" auf der Detailmaske der Machine (VM) zuweisen
* GitHub Repository anlegen
    * im Repository Datei `scripts/install.sh` anlegen (geht über die Weboberfläche von GitHub). Und folgenden Inhalt erfassen:

        
    #!/bin/bash
    sudo apt install -y apache2
        
* In der Machine (VM) im Feld Note den URL des GitHub Repositories eintragen
    * -> Deploy Ubuntu 18.04....

Wenn es läuft ist die Standardseite des Apache Servers auf der IP 192.168.161.21 (auf Eure IP Anpassen) ersichtlich. 
 
* GitHub Repository bzw. scripts/install.sh editieren und z.B. ändern auf:

    
    #!/bin/bash
    sudo apt install -y nginx
    
    * -> Release -> Deploy der Machine (VM).  

auf 192.168.161.21 ist die Startseite des nxinx Web Server ersichtlich.

Wenn alles Funktioniert, URL des GitHub Repositories mit Angaben wie RAM, Storage und CPUs an Projekt [lernmaas](https://github.com/mc-b/lernmaas) senden, z.B. als [Issue](https://github.com/mc-b/lernmaas/issues).

**Wie Installiere ich Software, für dies es kein Debian Packet gibt?**

Mittels `wget`.

Beispiel `ngrok`

* Öffne die Website von [ngrok](https://ngrok.com/) gehe auf [Download](https://ngrok.com/download).
* Kopiere den [Linux URL](https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip) in die Zwischenablage
* Wechsel in die Machine (VM) oder auf das Installationsscripts und füge folgende Befehle ein:

    sudo apt install unzip
    wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -O ngrok.zip
    unzip ngrok.zip
    sudo mv ngrok /usr/local/bin
    chmod 755 /usr/local/bin/ngrok
    
    

Zugriff
-------

**Wie kann ich auf die Machine (VMs) zugreifen?**

Das kommt auf Einträge in [config.yaml](https://github.com/mc-b/lernmaas#konfigurationsdatei-configyaml) an. Es sind SSH, SMB und mittels Password möglich.

**Wie setze ich ein Default Password für den 'ubuntu' User und schalten den Zugriff mit dem Password via SSH frei?**

    sudo bash -c 'chpasswd <<<ubuntu:changeme'
    sudo sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo systemctl restart sshd



Persistenz / Vorlagen
---------------------

**Sind meine Daten nach dem "Release" der Machine (VM) noch vorhanden?**

* Ja, wenn Service NFS aktiviert und sie im $HOME/data des Users ubuntu abgelegt wurden. Dann findet man sich auf dem Rack Server unter /data/storage/<hostname>.

**Wo kann ich Vorlagen für die Lernenden hinterlegen**

* Im Verzeichnis /data/templates auf dem Rack Server. Dieses wird in die Machine (VM) als $HOME/templates gemountet.
* Besser ist es jedoch die Vorlagen in einem GitHub Repository abzulegen. Dieses wird in $HOME Verzeichnis geclont.

**Wo kann ich Konfigurationen hinterlegen, wo nur während dem Installationsprozess sichtbar sind?**

* Am einfachsten auf dem Rack Server im Verzeichnis /data/config. Das ist nur während dem Installationsprozess als $HOME/config verfügbar.

VPN (WireGuard)
---------------

**Wie kann ich mehrere VPNs gleichzeitig im Zugriff haben?** 

* Dazu muss man den gleichen WG-Key für mehrere VPNs hinterlegen.
    * Mittels `createkeys ...` Konfigurationsdatei wgX.conf anlegen. 
    * Anzahl gewünschte Eintrage z.B. Client 1 - Client 10 in Datei `wg-global.conf` speichern und dritte Stelle auf ${NET} und vierte Stelle der IP-Adressen auf > 120 ändern. Das Resultat sieht etwa so aus:

    
    ### Client 1 (...Private.Key_1...)
    [Peer]
    PublicKey = ...Public.Key.1...
    AllowedIPs = 192.168.${NET}.120
    
    ### Client 2 (...Private.Key.2...)
    [Peer]
    PublicKey = ...Public.Key.2...
    AllowedIPs = 192.168.${NET}.121

* Der Inhalt der Datei `wg-global.conf` entweder auf dem Gateway hinten an die `wgX.conf` Dateien anhängen (${NET}) durch IP des VPN ersetzen) oder eine der Helper Scripts (createkeys, updateaz) verwenden. Die Datei `wg-global.conf` wird automatisch hinten angefügt.

* Auf dem Client kommt der `...Private.Key_1...`, alle IP-Adressen und alle Endpoints (siehe jeweiliges WG-Template) in die Konfigurationsdatei. Das Resulat sieht in etwa so aus:

    [Interface]
    PrivateKey = ...Private.Key_1...
    Address = 192.168.10.20/24, 192.168.111.120/24, 192.168.112.120/24
    [Peer]
    PublicKey = ......
    AllowedIPs = 192.168.10.0/24
    Endpoint = gateway.....com:51820
    [Peer]
    PublicKey = ......
    AllowedIPs = 192.168.111.0/24
    Endpoint = gateway.....com:51981

