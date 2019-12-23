#!/bin/bash
#
#   Anweisungen fuer cloud-init Aufbereiten
#

# Umgebung setzen
HOST=$(hostname | cut -d- -f 1)
NO=$(hostname | cut -d- -f 2)
MOD=$(grep "${HOST}="config.txt | cut -d= -f2)

## Module fuer Cloud-Init aufbereiten

for m in ${MOD}
do
    cp ${m} /etc/cloud/cloud.cfg.d/
done 
