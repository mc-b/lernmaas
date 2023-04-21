#!/bin/bash
#
#   Erstellen von GNS3 Templates anhand config.yaml
#   Die config.yaml Datei wird direkt vom github geholt.
#

function parse_yaml 
{
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   curl https://raw.githubusercontent.com/mc-b/lernmaas/master/config.yaml |
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=%s\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

###
#   Image holen

if  sudo [ ! -f /opt/gns3/images/QEMU/jammy-server-cloudimg-amd64.img ]
then
    echo "get Ubuntu Cloud-init Image"
    sudo apt-get install -y genisoimage
    sudo wget -O /opt/gns3/images/QEMU/jammy-server-cloudimg-amd64.img https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
    sudo qemu-img resize /opt/gns3/images/QEMU/jammy-server-cloudimg-amd64.img +30G
    sudo rm -f "/opt/gns3/images/QEMU/jammy-server-cloudimg-amd64.img.md5sum"
fi

###
# Cloud-init ISO-Dateien erstellen

echo "create Cloud-init ISO Images"
for MODUL in $(parse_yaml config.yaml | cut -d_ -f1 | sort | uniq | grep '^m[1-9]')
do
    echo ${MODUL}
    echo -e "instance-id: ${MODUL}\nlocal-hostname: ${MODUL}" > meta-data
    curl https://raw.githubusercontent.com/mc-b/lernmaas/master/gns3/cloud-init.yaml >user-data
    sudo mkisofs -output "/opt/gns3/images/QEMU/lernmaas-cloud-init-${MODUL}.iso" -volid cidata -joliet -rock {user-data,meta-data}
    sudo rm -f "/opt/gns3/images/QEMU/lernmaas-cloud-init-${MODUL}.iso.md5sum"
done

###
# Template erzeugen

echo "create GNS3 Templates"
for MODUL in $(parse_yaml config.yaml | cut -d_ -f1 | sort | uniq | grep '^m[1-9]')
do
    for e in $(eval parse_yaml | grep "^${MODUL}" | sed "s/^${MODUL}/config/")
    do
        export $e
    done
    
cat <<EOF >template
{
    "cdrom_image": "lernmaas-cloud-init-${MODUL}.iso",
    "compute_id": "local",
    "console_type": "telnet",
    "cpus": ${config_vm_cores},
    "hda_disk_image": "jammy-server-cloudimg-amd64.img",
    "name": "${MODUL}",
    "qemu_path": "/bin/qemu-system-x86_64",
    "ram": ${config_vm_memory}  ,
    "template_type": "qemu",
    "symbol": ":/symbols/affinity/circle/gray/vm.svg",    
    "usage": "Modul ${MODUL}"
}
EOF
    
    echo ${MODUL}
    curl -X POST "http://localhost:3080/v2/templates" -d "@template" 
    
done    

