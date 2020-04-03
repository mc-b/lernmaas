Gateway Server
==============

*Das Wort Gateway bezeichnet in der Informatik eine Komponente, welche zwischen zwei Systemen eine Verbindung herstellt.*

Im nachfolgenden ist beschrieben wie mittels eines Gateways die VMs innerhalb der Organisation gegen Aussen sichtbar gemacht werden können.

Server
------

Als erstes ist ein öffentlich zugänglicher Server mit Linux einzurichten. 

Dazu eignen sich die Standard Angebote der Cloud Anbieter wie:
* [Amazon Lightsail](https://aws.amazon.com/de/lightsail)
* [Azure VMs](https://azure.microsoft.com/de-de/services/virtual-machines/)
* [Google](https://cloud.google.com/compute/docs/quickstart-linux)

Vom Leistungsumfang hat sich 
* 1 vCPU
* 1 GB RAM
* 8 GB HD
bewährt.

Die Standard Installation von Linux mit SSH Server ist ausreichend.

Ein Web Server ist dann sinnvoll, wenn die Zugriffsinformation direkt auf dem Gateway angezeigt werden sollen. Siehe z.B. [http://gateway.northeurope.cloudapp.azure.com/](http://gateway.northeurope.cloudapp.azure.com/).

VPN 
---

*Das konventionelle VPN bezeichnet ein virtuelles privates (in sich geschlossenes) Kommunikationsnetz. Virtuell in dem Sinne, dass es sich nicht um eine eigene physische Verbindung handelt, sondern um ein bestehendes Kommunikationsnetz, das als Transportmedium verwendet wird. Das VPN dient dazu, Teilnehmer des bestehenden Kommunikationsnetzes an ein anderes Netz zu binden.*

Als VPN verwenden wir [WireGuard](https://www.wireguard.com/). 

### VMs für VPN einrichten

Zuerst Melden wir uns mittel ssh beim MAAS Server an und erzeugen die benötigten VMs und WireGuard Konfigurationen.

Die VMs sind in MAAS Resource Pools angeordnet. Diese werden automatisch durch das Helper Script [createvms](https://github.com/mc-b/lernmaas/tree/master/helper#createvms) erstellt.

Beispiel:

    cd lernmaas
    createvms config.yaml m242 20 st17a
    
Erstellt 20 VMs für die Klasse st17a und Modul 242. Die 20 VMs stehen im Resource Pool `m242-st17a` zur Verfügung.

Als nächsten Schritt erzeugen wir die VPN Konfiguration mittels des Helper Scripts [createkeys](https://github.com/mc-b/lernmaas/tree/master/helper#createkeys).

    createkeys gateway.northeurope.cloudapp.azure.com 51821 m242-st17a     

Das Script erzeugt folgende Ausgabe:

    Key Generierung erfolgreich
    ---------------------------
    
    wg1.conf            - WireGuard Konfigurationsdatei fuer Gateway
    wg1-template.conf   - WireGuard Template fuer Clients. Vervollstandigen mit IP-Adresse und Private-Key. Ablegen zu den Unterlagen
    wg1.csv             - Liste der Clients. Zum Bearbeiten mit Excel und Eintragen der Lernenden
    m242-st17a.html     - HTML Seite mit Servern und Clients zum Ablegen auf dem Gateway
    HOSTNAME.conf       - Konfigurationsdateien fuer die VMs. In Verzeichnis /data/config/wireguard kopieren.
    
    WireGuard Interface auf dem Gateway aktiveren:
    systemctl enable wg-quick@wg1.service
    systemctl start wg-quick@wg1.service

Die Ausgabe ist wie folgt zu interpretieren:
* `wg1.conf` auf Gateway Server kopieren
* `wg1-template.conf` und `wg1.csv` brauchen wir als Vorlage und Liste der VPN Teilnehmer mit Ihren Keys und IP-Adressen.
* `HOSTNAME.conf` hier die Dateien `m242-[01 - 20]-st17a.conf` sind nach `/data/config/wireguard` zu kopieren.
* `m242-st17a.html` ist sinnvoll wenn auf dem Gateway Server ein Web Server läuft, hier stehen die IP-Adressen der VMs und Keys.

Damit ist die Installation auf dem MAAS Server abgeschlossen, beim nächsten Deployen der VMs wird automatisch ein VPN Interface erzeugt und die VM damit ins VPN integriert.

### Gateway Server - VPN 

Auf dem Gateway Server ist WireGuard zu installieren:

    sudo -i
    add-apt-repository -y ppa:wireguard/wireguard
    apt-get update
    apt-get install -y wireguard
    
Und die, auf dem MAAS Server erzeugte, Konfigurationsdatei `wg1.conf` nach `/etc/wireguard` zu kopieren und WireGuard zu aktiveren 

    systemctl enable wg-quick@wg1.service
    systemctl start wg-quick@wg1.service
    
Anschliessend noch die IP Weiterleitung aktiveren. Dazu ist in der Datei `/etc/sysctl.conf` der folgende Eintrag zu aktivieren:

    # Uncomment the next line to enable packet forwarding for IPv4
    net.ipv4.ip_forward=1

Gateway Server frisch starten es sollte neu ein Interface `wg1` vorhanden sein.

    sudo ifconfig
    sudo wg    

Weiter geht es mit [VPN Client Anbindung](GatewayClient.md).

Portweiterleitung
-----------------

*Eine Portweiterleitung (englisch port forwarding) ist die Weiterleitung einer Verbindung, die über ein Rechnernetz auf einem bestimmten Port eingeht, zu einem anderen Computer.*

Der Gateway Server kann zur Portweiterleitung der VMs eingesetzt werden. 

Dazu ist wie folgt vorzugehen:

**Datei `/etc/ssh/sshd_config` editieren und TCP Forwarding und Gateway Ports aktivieren, alle anderen Weiterleitungen deaktivieren:**


    #AllowAgentForwarding yes
    AllowTcpForwarding yes
    GatewayPorts yes
    X11Forwarding no

**Separaten SSH Key für TCP Forwarding erstellen, als User `ubuntu`, z.B. mit Namen `ssh_tunnel`**

    ssh-keygen -C "ssh-tunnel@gateway.northeurope.cloudapp.azure.com" 
    
    
Den erstellen SSH **Public Key** unter `~/.ssh/authorized_keys`, unter Voranstellung von `command="/bin/false",no-pty,no-X11-forwarding,no-user-rc`, eintragen. Das Resultat sieht dann etwa so aus:

    command="/bin/false",no-pty,no-X11-forwarding,no-user-rc ssh-rsa A....XZ ssh-tunnel@gateway.northeurope.cloudapp.azure.com

mittels diesem Eintrag können VMs zwar eine Portweiterleitung über gateway.northeurope.cloudapp.azure.com einrichten, aber nicht auf dem Gateway Server einlogen.
      
**Private Key `.ssh/ssh_tunnel` auf MAAS Server in Verzeichnis `/data/config/ssh` kopieren**

* Datei von `ssh_tunnel` auf `<Modulname>_tunnel` ändern. In unserem Beispiel heisst die Datei neu `m242_tunnel`.
* VMs auf dem MAAS Server deployen und es wird automatisch eine Datei `/home/ubuntu/.ssh/ssh_tunnel` auf jeder VMs erzeugt.
* Port weiterleiten wie auf [Portweiterleitung](GatewayClient.md#portweiterleitung) beschrieben.

Quellen
-------
* [Gateway](https://de.wikipedia.org/wiki/Gateway_(Informatik)) 
* [VPN](https://de.wikipedia.org/wiki/Virtual_Private_Network)
* [Portweiterleitung](https://de.wikipedia.org/wiki/Portweiterleitung) 
