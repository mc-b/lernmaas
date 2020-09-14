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

### Installation VM via Azure UI

![](../images/azure-cloud.png)

---

Beim Azure UI ist unter `Erweitert` der Inhalt der obigen Datei anzugeben.

Ausserdem ist, je nach Anforderungen, auf die richtige Grösse vom RAM und HD zu achten.

### Installation via Azure CLI

Nach der [Installation des Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) auf der lokalen Maschine, kann die VM mittels diesem angelegt werden. 

Für das Modul [M122](https://github.com/tbz-it/M122) sieht das z.B. wie folgt aus.

Erstelen der `cloud-init.cfg` Datei und SSH-Key mit `export VMNAME=m122-02`, wie oben beschrieben.

Anmelden an der Azure Cloud und erstellen einer Ressource Gruppe, wo unsere VMs abgelegt werden:

    az login
    az group create --name m122 --location northeurope
    
Erstellen der VM    
    
    az vm create --resource-group m122 --name m122-02 --image UbuntuLTS --location northeurope --custom-data cloud-init.cfg    
  
Bei erfolgreicher Installation wird die IP-Adresse der VM ausgegeben.

Kopieren der Zugriffsinformationen auf die lokale Maschine. Aus Sicherheitsgründen, löschen wir diese Informationen auf der VM weg.

    scp -i id_rsa -rp <ip vm>:data/.ssh .
    ssh -i id_rsa <ip vm> rm -rf data/.ssh
    
Jetzt können wir die Ports der VM freigeben.

    az vm open-port --port 80 --resource-group m122 --name m122-02

Um die VM und alle Ressourcen wieder freizugeben, verwenden wir:

    az group delete --name m122 -f

### Links

* [Create a Linux server VM by using the Azure CLI in Azure Stack Hub](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-quick-create-vm-linux-cli?view=azs-1908)
* [How to use cloud-init to customize a Linux virtual machine in Azure on first boot](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-automate-vm-deployment)

### Hinweise

**Bei den VMs wird davon ausgegangen, dass sie in einem geschützten Umfeld (VPN) laufen. Deshalb werden Zugriffsinformationen wie Passwörter etc. in der Web Oberfläche angezeigt.**

* VMs mittels VPN, z.B. [WireGuard](https://www.wireguard.com/), absichern. Die Abhandlung ist in lernMAAS vorhanden, muss aber für die Cloud angepasst werden.
* Die Abhandlung findet man im Script [wireguard.sh](https://github.com/mc-b/lernmaas/blob/master/services/wireguard.sh).

WireGuard erwartet die Konfigurationsdatei als `/home/ubuntu/config/wireguard/$(hostname).conf`. 

Diese Datei kann mittels Erweiterung der `cloud-init.cfg` Datei erzeugt werden.

    # cloud-config
    write_files:
    - owner: ubuntu:ubuntu
      path: /home/ubuntu/config/wireguard/${VNMAME}.conf
      content: |
      [Interface]
        PrivateKey = .....
        Address = 10.1.40./24
        
        [Peer]
        PublicKey = ....
        AllowedIPs = 10.1.40.0/24
        Endpoint = wireguard.gateway.ch:51820

**Persistenter Speicher**

* In einer [MAAS](https://maas.io) wird das Verzeichnis `$HOME/data` auf dem Rack Server gespeichert und ist auch nach dem löschen der VM vorhanden.
* Der persistente Speicher wird im Script [nfs.sh](https://github.com/mc-b/lernmaas/blob/master/services/nfs.sh) verbunden.

**Kubernetes - .kube/config**

In der Konfigurationsdatei für `kubectl` von Kubernetes steht, je nach Cloud, eine interne IP-Adresse.

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
  
