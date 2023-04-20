#!/bin/bash
#
#   Erstellt Kubernetes Templates um Cluster zu erzeugen
#

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
# Cloud-init ISO Images und Templates erzeugen

# Master Nodes
for MODUL in 01 02 03 
do
    echo -e "instance-id: microk8s-${MODUL}-master\nlocal-hostname: microk8s-${MODUL}-master" > meta-data
    curl https://raw.githubusercontent.com/mc-b/lernmaas/master/gns3/cloud-init.yaml >user-data
    sudo mkisofs -output "/opt/gns3/images/QEMU/lernmaas-cloud-init-microk8s-${MODUL}-master.iso" -volid cidata -joliet -rock {user-data,meta-data}
    sudo rm -f "/opt/gns3/images/QEMU/lernmaas-cloud-init-microk8s-${MODUL}-master.iso.md5sum"
    
cat <<EOF >template
{
    "cdrom_image": "lernmaas-cloud-init-microk8s-${MODUL}-master.iso",
    "compute_id": "local",
    "default_name_format": "{name}",
    "console_type": "telnet",
    "cpus": 2,
    "hda_disk_image": "jammy-server-cloudimg-amd64.img",
    "name": "microk8s-${MODUL}-master",
    "qemu_path": "/bin/qemu-system-x86_64",
    "ram": 4096,
    "template_type": "qemu",
    "symbol": ":/symbols/affinity/circle/red/vm.svg",    
    "usage": "Kubernetes Master ${MODUL}"
}
EOF
    curl -X POST "http://localhost:3080/v2/templates" -d "@template"     
    
done

# Worker Nodes
for MODUL in 01 02 03 04 05
do
    echo -e "instance-id: microk8s-${MODUL}-worker\nlocal-hostname: microk8s-${MODUL}-worker" > meta-data
    curl https://raw.githubusercontent.com/mc-b/lernmaas/master/gns3/cloud-init.yaml >user-data
    sudo mkisofs -output "/opt/gns3/images/QEMU/lernmaas-cloud-init-microk8s-${MODUL}-worker.iso" -volid cidata -joliet -rock {user-data,meta-data}
    sudo rm -f "/opt/gns3/images/QEMU/lernmaas-cloud-init-microk8s-${MODUL}-worker.iso.md5sum"
    
cat <<EOF >template
{
    "cdrom_image": "lernmaas-cloud-init-microk8s-${MODUL}-worker.iso",
    "compute_id": "local",
    "default_name_format": "{name}",
    "console_type": "telnet",
    "cpus": 2,
    "hda_disk_image": "jammy-server-cloudimg-amd64.img",
    "name": "microk8s-${MODUL}-worker",
    "qemu_path": "/bin/qemu-system-x86_64",
    "ram": 2048,
    "template_type": "qemu",
    "symbol": ":/symbols/affinity/circle/red/vm.svg",    
    "usage": "Kubernetes Worker ${MODUL}"
}
EOF
    curl -X POST "http://localhost:3080/v2/templates" -d "@template"     
    
done 

 