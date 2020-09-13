lernMAAS in der Public Cloud
============================

Weil [lernMAAS](github.com/mc-b/lernmaas) [Cloud-init](https://cloudinit.readthedocs.io/)  zur Initialiserung der VMs verwendet kann [lernMAAS](github.com/mc-b/lernmaas) auf jeder öffentlichen Cloud (Google, IBM, [AWS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html), [Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init) etc.) eingesetzt werden.

Die entsprechende Cloud Plattform muss 
* Ubuntu Images (18.xx, besser 20.xx) 
* [Cloud-init](https://cloudinit.readthedocs.io/en/latest/topics/datasources.html)

unterstützen.

Dazu muss einmalig eine `cloud-init.cfg` Datei mit einem SSH-Key erstellt werden:

    export VMNAME=m122-20

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
