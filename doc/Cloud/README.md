lernMAAS in der Public Cloud
============================

Weil [lernMAAS](github.com/mc-b/lernmaas) [Cloud-init](https://cloudinit.readthedocs.io/)  zur Initialiserung der VMs verwendet kann [lernMAAS](github.com/mc-b/lernmaas) auf jeder öffentlichen Cloud (Google, IBM, [AWS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html), [Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init) etc.) eingesetzt werden.

Die entsprechende Cloud Plattform muss 
* Ubuntu Images (18.xx, besser 20.xx) 
* [Cloud-init](https://cloudinit.readthedocs.io/en/latest/topics/datasources.html)

unterstützen.

Dazu muss einmalig eine `cloud-init.cfg` Datei mit einem SSH-Key erstellt werden:

    export VMNAME=m300-01

    ssh-keygen -t rsa -b 4096 -f id_rsa -C cloud-init -N "" -q
    
    cat <<%EOF% >cloud-init.cfg
    #cloud-config
    hostname: ${VMNAME}
    fqdn: ${VMNAME}.northeurope.cloudapp.azure.com
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
    # login ssh and console with password
    ssh_pwauth: true
    disable_root: false
    packages:
      - git 
      - curl 
      - wget
      - jq
      - markdown
      - nmap
      - traceroute
    runcmd:
      - git clone https://github.com/mc-b/lernmaas /opt/lernmaas
      - sudo su - ubuntu -c "cd /opt/lernmaas && bash -x services/cloud-init.sh"
    %EOF%
    
Diese Datei ist, beim Erstellen der VM, in der Cloud, mitzugeben.  

![](../images/azure-cloud.png)

---

### Hinweise

**Bei den VMs wird davon ausgegangen, dass sie in einem geschützten Umfeld (VPN) laufen. Deshalb werden Zugriffsinformationen wie Passwörter etc. in der Web Oberfläche angezeigt.**

* VMs mittels VPN, z.B. [WireGuard](https://www.wireguard.com/), absichern. Die Abhandlung ist in lernMAAS vorhanden, muss aber für die Cloud angepasst werden.
* Die Abhandlung findet man im Script [wireguard.sh](https://github.com/mc-b/lernmaas/blob/master/services/wireguard.sh).

**Persistenter Speicher**

* In einer [MAAS](https://maas.io) wird das Verzeichnis `$HOME/data` auf dem Rack Server gespeichert und ist auch nach dem löschen der VM vorhanden.
* Der persistente Speicher wird im Script [nfs.sh](https://github.com/mc-b/lernmaas/blob/master/services/nfs.sh) verbunden.

**Kubernetes - .kube/config**

* In der Konfigurationsdatei für `kubectl` von Kubernetes steht, je nach dem, eine Cloud interne IP-Adresse.

    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: 
        server: https://10.0.1.4:6443

Diese ist durch den vollen DNS Namen (`hostname -f`) zu ersetzen

    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: 
        server: https://m300-01.northeurope.cloudapp.azure.com:6443
  
