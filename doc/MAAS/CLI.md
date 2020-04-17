MAAS CLI
--------

Die MAAS Kommandline eignet sich um mehrere VMs zu erstellen.

### Einloggen

    maas login ubuntu http://localhost:5240/MAAS/api/2.0

Den API Key findet man im MAAS UI unter `ubuntu`.

**Tip**: Profile als Umgebungvariable `PROFILE` in `.bashrc` speichern.
    
### Virtuelle Maschinen erzeugen     

Dazu brauchen wir zuerst die Id (fortlaufende Nummer) der Pods. Diese erhalten wir mittels folgendem Befehl:

    maas ${PROFILE} pods read | jq '.[] | .name, .id'
    
Von Vorteil ist es, die VMs in unterschiedliche Pools zu unterteilen. Dazu brauchen wir wieder die Ids:

    maas ${PROFILE} resource-pools read | jq '.[] | .id, .name, .description'    

Anschliessend können wir auf dem entsprechenden Pod (HW mit KVM) im gewünschten Pool unsere VMs erstellen:

    for x in {01..03} ; do maas ubuntu pod compose 3 memory=2048 cores=2 storage=16 pool=0 hostname=m300-${x} ; done  
    
### Links

* [MAAS CLI](https://maas.io/docs/maas-cli)
* [jq](https://wiki.ubuntuusers.de/jq/)