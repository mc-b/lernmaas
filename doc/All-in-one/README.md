All-in-one MAAS
===============

Der Server betreibt MAAS (Region- und Rack-Controller) und fungiert gleichzeitig als KVM-Host, über den MAAS virtuelle Maschinen provisionieren kann.

Installation
------------

Zuerst installieren wir ein Standard Ubuntu Desktop 24.x.

Und prüfen ob die HW Virtualisierung aktiviert ist

    kvm-ok

Dann folgt die Installation von KVM und den entprechenden Tools

    sudo apt update
    sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager genisoimage
    sudo usermod -aG libvirt $(whoami)

Standard Cloud Image holen

    mkdir vm
    cd vm
    wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
    sudo mv noble-server-cloudimg-amd64.img /var/lib/libvirt/images/
    
Cloud-Init ISO-CDROM und Disk aufbereiten     

    export MODUL=controller
    qemu-img create -f qcow2 -b /var/lib/libvirt/images/noble-server-cloudimg-amd64.img -F qcow2 maas-${MODUL}.qcow2 32G    

    echo -e "instance-id: ${MODUL}\nlocal-hostname: ${MODUL}" > meta-data
    curl https://raw.githubusercontent.com/mc-b/lernmaas/master/scripts/cloud-init-maas.yaml >user-data
    mkisofs -output "maas-${MODUL}.iso" -volid cidata -joliet -rock {user-data,meta-data}
    
    sudo mv maas-${MODUL}.qcow2 /var/lib/libvirt/images/
    sudo mv maas-${MODUL}.iso /var/lib/libvirt/images/

VM Starten

    virt-install \
      --name maas-${MODUL} \
      --ram 4096 \
      --vcpus 2 \
      --os-variant ubuntu24.04 \
      --disk path=/var/lib/libvirt/images/maas-${MODUL}.qcow2,format=qcow2 \
      --disk path=/var/lib/libvirt/images/maas-${MODUL}.iso,device=cdrom \
      --import \
      --network bridge=virbr0 \
      --graphics none \
      --console pty,target_type=serial
      
Netzwerk
--------

Bei `default` Netzwerk muss von `nat` nach `route` und `dhcp` deaktiviert werden.

    virsh net-dumpxml default >default.xml      
    cat <<EOF >default.xml
    <network>
      <name>default</name>
      <uuid>4de711b3-d0ec-44c2-aea8-4698e000e1f8</uuid>
      <forward mode='route'>
      </forward>
      <bridge name='virbr0' stp='on' delay='0'/>
      <mac address='52:54:00:a8:cb:97'/>
      <ip address='192.168.122.1' netmask='255.255.255.0'>
      </ip>
    </network>
    EOF
    
    virsh net-destroy default
    virsh net-undefine default
    
    virsh net-define default.xml
    virsh net-autostart default
    virsh net-start default
    
    # IP Forward einrichten, wegen `route`
    sudo iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -o eno1 -j MASQUERADE
    sudo iptables -I FORWARD -s 192.168.122.0/24 -o eno1 -j ACCEPT
    sudo iptables -I FORWARD -d 192.168.122.0/24 -i eno1 -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Regeln persistieren
    sudo apt install iptables-persistent
    
User `virsh`
-------------

    sudo useradd -m -s /bin/bash virsh
    echo 'virsh:insecurepassword' | sudo chpasswd
    sudo usermod -aG libvirt virsh
    

KVM-Host hinzufügen
--------------------

    maas ubuntu vm-hosts create type=virsh \
    power_address=qemu+ssh://virsh@192.168.122.1/system \
    name=localhost
    
Bestätigen inkl. Password im MAAS.io      
      