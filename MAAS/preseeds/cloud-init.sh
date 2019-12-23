#!/bin/bash
#
#   Anweisungen fuer cloud-init Aufbereiten
#

# Umgebung setzen
HOST=$(hostname | cut -d- -f 1)
NO=$(hostname | cut -d- -f 2)
MOD=$(grep "${HOST}=" config.txt | cut -d= -f2)

## Module fuer Cloud-Init aufbereiten - es muss alles in einer Datei stehen!

for m in ${MOD}
do
    cat cloud.cfg.d/${m} >>/etc/cloud/cloud.cfg.d/99_lernmaas.cfg
done 
