Virtualisierte Machinen in Virtualisierten Machinen (VM in VM)
---------------------------------------------------

KMV ermöglicht es die Virtualisierung zu verschachteln. D.h. bei entsprechender Konfiguration der VM kann KMV oder VirtualBox innerhalb der VM ausgeführt werden.

Vorbereiten der VM für verschachtelte Virtualisierung.

Dazu ist erst in die KVM Machine zu wechseln und dann mittels `virsh` die Einstellungen der VM zu ändern.

    virsh edit <vmname>
    
Der Befehl startet ein Editor und zeigt die Konfiguration im XML-Format an. 
Um die Virtualisierung in der VM zu aktivieren sind folgende Zeilen innerhalb von `<domain` einzufügen: 
    
    <cpu mode='host-passthrough' check='none'>
    </cpu>
    
VM mit neuer Konfiguration starten

    virsh shutdown <vmname>
    virsh start <vmname>
    virsh console <vmname>
    
Beenden mittels `Ctrl+AltGR+]`

### VM in VM - Vagrant

Benötigte Software installieren

    sudo apt-get install -y virtualbox vagrant
    
Einfache VM, ohne Zusatzsoftware, erstellen

    mkdir vminvm
    cd vminvm
    vagrant init ubuntu/xenial64
    vagrant up
    vagrant ssh
    
Testen des Web Beispiels von Modul [M300](https://github.com/mc-b/M300).

    git clone https://github.com/mc-b/M300
    cd M300/vagrant/web
    vagrant up
    vagrant port
    curl localhost:8080
    
Es wird die Webseite des Apache Servers in der VM angezeigt.    

### VM in VM - mit KVM und Cloud-init

Benötigte Software installieren

    sudo apt-get install -y cloud-image-utils virtinst qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils whois

Standard Ubuntu 18.04 Image holen und Snapshot davon erstellen, inkl. Vergrösserung FS auf 30 GB, am besten in einem separaten Verzeichnis


    mkdir vminvm
    cd vminvm
    wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
    qemu-img create -b bionic-server-cloudimg-amd64.img -f qcow2 bionic-server-cloudimg.qcow2 30G
    qemu-img info bionic-server-cloudimg.qcow2
    
SSH-Key zum ablegen in VM anlegen

    ssh-keygen -t rsa -b 4096 -f id_rsa -C cloud-init -N "" -q 

Cloud-init Konfigurationsdatei erzeugen

    cat <<%EOF% >cloud-init.cfg
    #cloud-config
    hostname: ubuntu
    fqdn: ubuntu.maas.com
    manage_etc_hosts: true
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, admin
        home: /home/ubuntu
        shell: /bin/bash
        lock_passwd: false
        ssh-authorized-keys:
          - $(cat id_rsa.pub)
    # login ssh and console with password ubuntu
    ssh_pwauth: true
    disable_root: false
    chpasswd:
      list: |
         ubuntu:ubuntu
      expire: False
    packages:
      - qemu-guest-agent
      - apache2
    # written to /var/log/cloud-init-output.log
    final_message: "The system is finally up, after \$UPTIME seconds"
    %EOF%
    
Netzwerk Konfiguration. Als Gateway wird das Netzwerk des KVM Server (immer 192.168.122.0/24) verwendet. Die IP-Adresse ist fix.

    cat <<%EOF% >network-config.cfg
    version: 2
    ethernets:
      ens3:
         dhcp4: false
         # default libvirt network
         addresses: [ 192.168.122.158/24 ]
         gateway4: 192.168.122.1
         nameservers:
           addresses: [ 192.168.122.1,8.8.8.8 ]
           search: [ maas.com ]
    %EOF%

Generieren eines lokalen Disk mit den obigen Konfigurationen

    cloud-localds -v --network-config=network-config.cfg bionic-server-cloud.qcow2 cloud-init.cfg

Starten der VM

    virt-install --name ubuntu --virt-type kvm --memory 512 --vcpus 2 --boot hd,menu=on \
                 --disk path=bionic-server-cloud.qcow2,device=cdrom \
                 --disk path=bionic-server-cloudimg.qcow2,device=disk \
                 --graphics vnc,port=5910,listen=0.0.0.0 \
                 --os-type Linux --os-variant ubuntu18.04 \
                 --network network:default \
                 --console pty,target_type=serial &
                
Verbinden mit der erstellen VM

    ssh -i id_rsa ubuntu@192.168.122.158     
    
Port, z.B. 80 weiterleiten an den Host und für alle sichtbar machen

    ssh -i id_rsa -N -L '0.0.0.0:8080:localhost:80' 192.168.122.158 &                

VM beenden und aufräumen

    virsh destroy ubuntu
    virsh undefine ubuntu
    rm -f bionic-server-cloud.qcow2 
    rm -f bionic-server-cloudimg.qcow2
    qemu-img create -b bionic-server-cloudimg-amd64.img -f qcow2 bionic-server-cloudimg.qcow2 30G

Anschliessend können die Konfigurationsdateien verändert und bei `cloud-localds` neu angefangen werden.



### Links

* [Blogeintrag](https://fabianlee.org/2020/02/23/kvm-testing-cloud-init-locally-using-kvm-for-an-ubuntu-cloud-image/)
* [GitHub](https://github.com/fabianlee/local-kvm-cloudimage)
* [Cloud-init](https://cloudinit.readthedocs.io/)