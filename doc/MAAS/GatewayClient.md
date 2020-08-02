Einbinden der VPN Clients
-------------------------

Auf jedem Client muss das VPN [WireGuard](https://www.wireguard.com/install/) installiert und konfiguriert werden.

Ist die VM zugreifbar können in einem zweiten Schritt die Services, z.B. ein Web Server, mittels [Portweiterleitung](#portweiterleitung) im Internet zur Verfügung gestellt werden.

### VPN

*Das konventionelle VPN bezeichnet ein virtuelles privates (in sich geschlossenes) Kommunikationsnetz. Virtuell in dem Sinne, dass es sich nicht um eine eigene physische Verbindung handelt, sondern um ein bestehendes Kommunikationsnetz, das als Transportmedium verwendet wird. Das VPN dient dazu, Teilnehmer des bestehenden Kommunikationsnetzes an ein anderes Netz zu binden.*

Installieren von [WireGuard](https://www.wireguard.com/install/) auf dem Client, dass kann ein Notebook, Raspberry Pi o.ä. sein.

In den Unterlagen zum Modul/Kurs finden Sie eine Vorlagen, z.B. `wg1-template.conf` und eine Liste von IP-Adressen der Server und Ihren Key und IP-Adresse für das VPN Netzwerk.

Vervollständigen Sie die Vorlage und ersetzen dabei die Einträge `<replace IP>` und `<replace Key>` durch Ihre Werte laut Liste.

Die Konfigurationsdatei sieht in etwa so aus:

    [Interface]
    Address = <replace IP>/24
    PrivateKey = <replace Key>
    
    [Peer]
    PublicKey = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    Endpoint  = yyyyyyyyyyyyyyyyyy:518zz
    
    AllowedIPs = 192.168.xx.0/24
    
    # This is for if you're behind a NAT and
    # want the connection to be kept alive.
    # PersistentKeepalive = 25

Handelt es sich beim Client z.B. um einen Raspberry Pi, welcher für andere im VPN sichtbar sein soll, aktivieren Sie den Eintrag `PersistentKeepalive` bzw. kommentieren diesen aus.

**Vorsicht:** Dadurch ist die IP-Adresse und alle Ports für alle im VPN sichtbar. Sollte in Unternehmensnetzwerken nur nach Rücksprache mit dem Sicherheitsverantwortlichen aktiviert werden.

Starten Sie die WireGuard Software und fügen die ergänzte Vorlage WireGuard als Tunnel hinzu:

![](../images/wireguard-add.png)

Und aktivieren Sie den Tunnel:

![](../images/wireguard-activate.png)

Die VMs sind nun mittels IP-Adresse inkl. allen Ports im VPN sichtbar.

### Portweiterleitung (optional)

*Eine Portweiterleitung (englisch port forwarding) ist die Weiterleitung einer Verbindung, die über ein Rechnernetz auf einem bestimmten Port eingeht, zu einem anderen Computer.*

![](https://res.cloudinary.com/canonical/image/fetch/q_auto,f_auto,w_860/https://dashboard.snapcraft.io/site_media/appmedia/2018/08/overview_JqV9JC2.png)

Quelle: https://snapcraft.io/install/ngrok/ubuntu
- - -

[ngrok](https://ngrok.com/) ist ein Reverse-Proxy, der einen sicheren Tunnel von einem öffentlichen Endpunkt zu einem lokal (in der MAAS Cloud) ausgeführten Webdienst erstellt.

Mittels [ngrok](https://ngrok.com/) können wir die installierten Services in der MAAS Cloud öffentlich verfügbar machen.

**Installation**

    sudo snap install ngrok
    
**Beispiel Apache Server**

    sudo apt install apache2
    ngrok http 80

### Quellen

* [VPN](https://de.wikipedia.org/wiki/Virtual_Private_Network)
* [Portweiterleitung](https://de.wikipedia.org/wiki/Portweiterleitung) 
* [How to install ngrok on Ubuntu](https://snapcraft.io/install/ngrok/ubuntu)

