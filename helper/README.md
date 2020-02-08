Hilfsscripts
============

Um die Scripts auszuführen, muss:
* das MAAS CLI installiert sein
* ein login in den MAAS Master stattgefunden haben
* die Umgebungsvariable PROFILE (= MAAS User) gesetzt sein.

ccopy
-----

`ccopy` exportiert die Container Images von einer laufenden Docker und/oder Kubernetes Umgebung nach `/data/templates/cr-cache/<Modul>` auf den MAAS Master.

`lernmaas` bzw. das Script [docker](../services/docker) verwendet diese exportieren Container Images und importiert diese, bevor der erste Container gestartet wird.

Das führt zu einem massiven Zeitgewinn, weil die Container Images nicht mehr über das Internet geholt werden müssen. Bei Kubernetes sind das alleine ca. 2 GB pro VM.

Der Aufruf von `ccopy` ist wie folgt:

    bash ccopy <Name Modul ohne -01> <IP-Adresse VM>

createvms
---------

Erstellt einen Resource Pool und darin die Anzahl VMs anhand der [config.yaml](../config.yaml) Datei.

Die VMs sind anschliessend im Zustand `Ready` und können via MAAS Oberfläche deployt werden.

Der Aufruf von `createvms` ist wie folgt:

    createvms <config.yaml> <Modul> <Anzahl VMs> <Suffix>
    
**ACHTUNG**: die Anzahl VMs muss kleiner der Anzahl Pods oder durch die Anzahl Pods teilbar sein. Z.B. bei 6 Pods können 1 - 6, 12, 18, 24 etc. VMs erstellt werden.    
    
createk8svms
------------

Erstellt einen oder mehrere Kubernetes Cluster. Die Anzahl bestimmt dabei die Anzahl Cluster und nicht die Anzahl VMs.

Es wird zuerst auf dem ersten KVM-Pod die Anzahl Master erstellt und anschliessend auf jedem weiteren KVM-Pod ein Worker. 

In der [config.yaml](../config.yaml) müssen die Einträge für master (z.B. m000master) und Worker (z.B. m000worker) vorhanden sind. Diese werden separat ausgewertet, d.h. dem Master kann z.B. weniger RAM zugewiesen werden als dem Worker oder umgekehrt.

Der Aufruf von `createvms` ist wie folgt:

    createk8svms <config.yaml> <Modul> <Anzahl Cluster> <Suffix>   

   
tocsv
--------

Exportiert VM Hostname und IP-Adresse ins CSV Format, z.B. um es mit Excel weiterverarbeiten zu können.

Hostname und IP-Adresse werden aus einem Resource Pool von MAAS Master geholt.

Der Aufruf von `tocsv` ist wie folgt:

    tocsv <Resource Pool MAAS>
    
createkeys
-----------

Erzeugt die WireGuard Keys für den Gateway.

    createkeys <EndPoint> <Port> <Resource Pool>  
    
Nach dem Aufruf der Scripts wird eine Anleitung für die weiteren Schritte ausgegeben, z.B. 

    Key Generierung erfolgreich
    ---------------------------
    
    wg0.conf            - WireGuard Konfigurationsdatei fuer Gateway
    wg0-template.conf   - WireGuard Template fuer Clients. Vervollstandigen mit IP-Adresse und Private-Key. Ablegen zu den Unterlagen
    wg0.csv             - Liste der Clients. Zum Bearbeiten mit Excel und Eintragen der Lernenden
    <Pool>.html         - HTML Seite mit Servern und Clients zum Ablegen auf dem Gateway
    
    WireGuard Interface auf dem Gateway aktiveren:
    systemctl enable wg-quick@wg0.service
    systemctl start wg-quick@wg0.service

   
    