Hilfsscripts
============

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