Hilfsscripts
============

Um die Scripts auszuführen, muss:
* das MAAS CLI installiert sein
* ein login in den MAAS Master stattgefunden haben
* die Umgebungsvariable PROFILE (= MAAS User) gesetzt sein.

ccopy.sh
--------

`ccopy.sh` exportiert die Container Images von einer laufenden Docker und/oder Kubernetes Umgebung nach `/data/templates/cr-cache/<Modul>` auf den MAAS Master.

`lernmaas` bzw. das Script [docker.sh](../services/docker.sh) verwendet diese exportieren Container Images und importiert diese, bevor der erste Container gestartet wird.

Das führt zu einem massiven Zeitgewinn, weil die Container Images nicht mehr über das Internet geholt werden müssen. Bei Kubernetes sind das alleine ca. 2 GB pro VM.

Der Aufruf von `ccopy.sh` ist wie folgt:

    bash ccopy.sh <Name Modul ohne -01> <IP-Adresse VM>

makevms.sh
----------

Erstellt einen Resource Pool und darin die Anzahl VMs anhand der [config.yaml](../config.yaml) Datei.

Die VMs sind anschliessend im Zustand `Ready` und können via MAAS Oberfläche deployt werden.

Der Aufruf von `makevms.sh` ist wie folgt:

    makevms.sh <config.yaml> <Modul> <Anzahl VMs> <Suffix>
    
tocsv.sh
--------

Exportiert VM Hostname und IP-Adresse ins CSV Format, z.B. um es mit Excel weiterverarbeiten zu können.

Hostname und IP-Adresse werden aus einem Resource Pool von MAAS Master geholt.

Der Aufruf von `tocsv.sh` ist wie folgt:

    tocsv <Resource Pool MAAS>
    
makekeys.sh
-----------

Erzeugt die WireGuard Keys für den Gateway.

    makekeys.sh <EndPoint> <Port> <Resource Pool>  
    
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

   
    