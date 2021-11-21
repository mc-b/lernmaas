#cloud-config
hostname: ${module}
fqdn: ${module}
manage_etc_hosts: true
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    home: /home/ubuntu
    shell: /bin/bash
    lock_passwd: false
    ssh-authorized-keys:
      - ${public_key}
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