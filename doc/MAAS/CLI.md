MAAS CLI
--------

Die MAAS Kommandline eignet sich um mehrere VMs zu erstellen.

### Einloggen

    maas login ubuntu http://localhost:5240/MAAS/api/2.0

Den API Key findet man im MAAS UI unter `ubuntu`.

**Tip**: Profile als Umgebungvariable `PROFILE` in `.bashrc` speichern.
    
### Virtuelle Maschinen erzeugen     

Dazu brauchen wir zuerst die Id (fortlaufende Nummer) der Pods (neu KVM). Diese erhalten wir mittels folgendem Befehl:

    maas ${PROFILE} pods read | jq '.[] | .name, .id'

Anschliessend können wir auf dem entsprechenden Pod (KVM Host) unsere VMs erstellen:

    maas ${PROFILE} pod compose 3 memory=2048 cores=2 storage=16 pool=0 hostname=m100-10
    
Von Vorteil ist es, die VMs in unterschiedliche Pools zu unterteilen. Dazu brauchen wir wieder die Ids:

    maas ${PROFILE} resource-pools read | jq '.[] | .id, .name, .description'    
    
Für das deploymen der VM mit einem Cloud-init Script braucht man die System-ID der VM und ein Cloud-init Script im Base64 Format.

    SYSTEM_ID=...
    maas ${PROFILE} machine deploy ${SYSTEM_ID} user_data=$(base64 cloud-init.cfg)

Ein vollständiges Beispiel mit 6 virtuellen Maschinen findet man im Kurs [virtar](https://github.com/mc-b/virtar).

Die dort beschriebene Umgebung kann wie folgt erstellt werden:


    # KVM ID holen
    KVM=$(maas $PROFILE pods read | jq ".[] | select (.name==\"$(hostname)\") | .id")
    
    # Resource Pools erstellen
    for POOLNAME in Einkauf Verkauf Rechnungswesen Versand
    do
        maas $PROFILE resource-pools create name=${POOLNAME}
    done
    
    # Zone (AZ) erstellen
    for ZONENAME in EinkaufVerkaufVersand Rechnungswesen
    do
        maas $PROFILE zones create name=${ZONE}
    done    
    
    # VMs erstellen
    POOL=$(maas $PROFILE resource-pools read | jq ".[] | select (.name==\"Einkauf\") | .id")
    ZONE=$(maas $PROFILE zones read | jq ".[] | select (.name==\"EinkaufVerkaufVersand\") | .id")    
    maas ${PROFILE} pod compose ${KVM} memory=2048 cores=1 storage=8 pool=${POOL} zone=${ZONE} hostname=XYZ-10-Lieferanten
    
    POOL=$(maas $PROFILE resource-pools read | jq ".[] | select (.name==\"Verkauf\") | .id")
    maas ${PROFILE} pod compose ${KVM} memory=2048 cores=1 storage=8 pool=${POOL} zone=${ZONE} hostname=XYZ-11-Kunden
    maas ${PROFILE} pod compose ${KVM} memory=2048 cores=1 storage=8 pool=${POOL} zone=${ZONE} hostname=XYZ-12-Produkte
    maas ${PROFILE} pod compose ${KVM} memory=2048 cores=1 storage=8 pool=${POOL} zone=${ZONE} hostname=XYZ-13-Bestellungen
    
    POOL=$(maas $PROFILE resource-pools read | jq ".[] | select (.name==\"Rechnungswesen\") | .id")
    ZONE=$(maas $PROFILE zones read | jq ".[] | select (.name==\"Rechnungswesen\") | .id")    
    maas ${PROFILE} pod compose ${KVM} memory=2048 cores=1 storage=8 pool=${POOL} zone=${ZONE} hostname=XYZ-14-Rechnungsstellung
    
    POOL=$(maas $PROFILE resource-pools read | jq ".[] | select (.name==\"Versand\") | .id")
    maas ${PROFILE} pod compose ${KVM} memory=4096 cores=2 storage=20 pool=${POOL} zone=${ZONE} hostname=XYZ-15-Versand

        
### Links

* [MAAS CLI](https://maas.io/docs/maas-cli)
* [jq](https://wiki.ubuntuusers.de/jq/)