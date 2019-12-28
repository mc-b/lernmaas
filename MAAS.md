MAAS
====

## Installation Software - MAAS Server

Als [Anforderungen](https://maas.io/docs/maas-requirements) wird ein Server mit 4.5 GB memory, 4.5 GHz CPU, and 45 GB of disk space gewünscht.

Für Testumgebungen genügt die Hälfte.

### Netzwerkbridge erstellen

Zuerst muss ein zusätzliches Interface, die Bridge `br0`, erstellt werden.

Diese leitet den IP Verkehr von der VM weiter ins Internet, ausserdem benötigt der MAAS Server eine fixe IP.

Datei `/etc/netplan/01-netcnf.yaml` editieren, bzw. ergänzen:

    # This file describes the network interfaces available on your system
    # For more information, see netplan(5).
    network:
      version: 2
      renderer: networkd
      ethernets:
        enp5s0:
          dhcp4: false
          dhcp6: false
      bridges:
        br0:
          dhcp4: false
          dhcp6: false
          interfaces: [enp5s0]
          addresses: [172.16.17.13/24]
          gateway4: 172.16.17.1
          nameservers:
           addresses: [10.62.98.8,10.62.99.8,8.8.8.8]
        
Aktiveren
          
    sudo netplan --debug apply   
    
### MAAS

    sudo add-apt-repository ppa:maas/stable -y  
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y maas jq
    sudo maas init --admin-username ubuntu --admin-password password --admin-email xx.yy@zz.ch

### UI von MAAS aufrufen [ip:5240](http://localhost:5240)

* SSH-Key z.B. `id_rsa.pub` manuell eintragen
* DNS Server eintragen. 
* Bei Subnets DHCP Server aktivieren auf 172.16.17.x, Gateway IP: 172.16.17.1 und DNS Server eintragen

**Server frisch starten, ansonsten werden die Änderungen nicht übernommen.**

* Images syncen

### Testen

DHCP Testen

    sudo nmap --script broadcast-dhcp-discover -e virbr0
    
Custom Box hinzufügen

    maas $profile boot-resources create name=custom/$imagedisplayname architecture=amd64/generic content=@$tgzfilepath    
    
***
## Installation KVM Hosts 

[![](https://img.youtube.com/vi/jj1M-YyCgD4/0.jpg)](https://www.youtube.com/watch?v=jj1M-YyCgD4)

MAAS Enlistment 

---

Am einfachsten ist es die weiteren Maschinen via Netzwerk (PXE Boot) zu booten und automatisch installieren zu lassen.

Weitere geht es bei [MAAS CLI](#maas-cli)

### Manuelle Konfiguration KVM Host

Wird ein Server manuell mit Ubuntu 18.x installiert ist er wie folgt zu konfiguieren:

KVM installieren

    sudo add-apt-repository ppa:maas/stable -y  
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils jq
 
User maas aufbereiten und Zugriff auf ubuntu geben (als user ubuntu)

    sudo chsh -s /bin/bash maas  
    sudo su - maas  
    ssh-keygen -f ~/.ssh/id\_rsa -N ''  
    logout  
    sudo cat ~maas/.ssh/id\_rsa.pub | tee -a ~/.ssh/authorized_keys

Testen

    sudo -H -u maas bash -c 'virsh -c qemu+ssh://ubuntu@localhost/system list --all'

### virsh Netzwerk entfernen/erweitern, weil von maas bedient

Da neu **MAAS** die Rolle des DHCP Server übernimmt, muss der DHCP Server von **virsh** abgeschaltet werden.

Das wird durch entfernen und neu erstellen des `default` Netzwerkes erreicht.
 
    sudo virsh net-list
    sudo virsh net-destroy default
    sudo virsh net-undefine default

    cat <<%EOF% >net.xml
        <network>
          <name>default</name>
          <uuid>9a05da11-e96b-47f3-8253-a3a482e445f5</uuid>
          <forward mode='nat'/>
          <bridge name='virbr0' stp='on' delay='0'/>
          <mac address='52:54:00:0a:cd:22'/>
          <ip address='192.168.122.1' netmask='255.255.255.0'>
          </ip>
        </network>
    %EOF%

    sudo virsh net-define net.xml
    sudo virsh net-autostart default  
    sudo virsh net-start default

Anschliessend wird eine Bridge `br0`, welche den Verkehr zum Interface `br0` weitereleitet erstellt.

    cat <<%EOF% >br0.xml
    <network>
      <name>br0</name>
      <forward mode='bridge'/>
      <bridge name='br0'/>
    </network>
    %EOF%

    sudo virsh net-define br0.xml
    sudo virsh net-start br0
    sudo virsh net-autostart br0

### Disk Pool einrichten

Optional kann ein Disk Pool eingerichtet werden. Standardmässig sollte dieser schon vorhanden sein.

    sudo virsh pool-define-as default dir - - - - "/var/lib/libvirt/images"  
    sudo virsh pool-autostart default  
    sudo virsh pool-start default 
 
### UI von MAAS aufrufen [ip:5240](http://localhost:5240)    
 
* Aktuelle Maschine als Pod eintragen
* Pod -> Compose VM
    
### Testen (optional)

    virt-install --name=test1-vm \
    --vcpus=1 \
    --memory=1024 \
    --cdrom=$HOME/cdrom/debian-9.9.0-amd64-netinst.iso \
    --disk size=5 \
    --os-variant=debian8  --graphic vnc

### Links

* [Ubuntu MAAS 2.2 Wake on LAN Driver Patch](https://github.com/yosefrow/MAAS-WoL-driver)
* [Bridge KVM](https://askubuntu.com/questions/1054350/netplan-bridge-for-kvm-on-ubuntu-server-18-04-with-static-ips)
* [Static IP Ubuntu 18](https://linuxconfig.org/how-to-configure-static-ip-address-on-ubuntu-18-04-bionic-beaver-linux)
* [broadcast-dhcp-discover](https://nmap.org/nsedoc/scripts/broadcast-dhcp-discover.html)
* [Setup Default Network](http://blog.programster.org/kvm-missing-default-network)

