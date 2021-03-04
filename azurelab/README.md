Azure Lab
=========

Weil [lernMAAS](github.com/mc-b/lernmaas) [Cloud-init](https://cloudinit.readthedocs.io/) zur Initialiserung der VMs verwendet, kann auch Azure Labs eingesetzt werden.

Die entsprechende Cloud Plattform muss 
* Ubuntu Images (18.xx, besser 20.xx) 
* [Cloud-init](https://cloudinit.readthedocs.io/en/latest/topics/datasources.html)

unterstützen.

Dazu muss einmalig eine `99-lernmaas.cfg` Datei mit einem SSH-Key, Modul-Name erstellt werden.

    export MODUL=m300
    export KEY=id_remote.pub
    
    cat <<%EOF% >99-lernmaas.cfg
    #cloud-config
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, admin
        home: /home/ubuntu
        shell: /bin/bash
        lock_passwd: false
        ssh-authorized-keys:
          - $(cat ${KEY})
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
      - hostname ${MODUL}-\$(printf "%02d" \$(hostname -I | cut -d' ' -f1 | cut -d. -f4))
      - sudo su - ubuntu -c "cd /opt/lernmaas && bash -x services/cloud-init.sh"
    %EOF%

Die `99-lernmaas.cfg` kopiert man auf die Vorlage-VM und führt folgende Befehle aus:

    sudo mv 99-lernmaas.cfg /etc/cloud/cloud.cfg.d/
    sudo cloud-init clean
    sudo shutdown -h now
    
Bei Veröffentlichen der Vorlage-VM wird die VM kopiert und auf jeder neu erstellen VM, [Cloud-init](https://cloudinit.readthedocs.io) neu ausgeführt.

