#!/bin/bash
#
#   Repository https://github.com/mc-b/virtar - Von der Virtualisierung über Cloud und Container bis Serverless
#
#   MAAS in MAAS mit LXD als KVM Host

# MAAS installieren, User: ubuntu, PW: password
sudo add-apt-repository ppa:maas/3.0-next
sudo apt update
sudo apt install -y maas jq markdown nmap traceroute git curl wget zfsutils-linux cloud-image-utils virtinst qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils whois
sudo maas createadmin --username ubuntu --password password --email marcel.bernet@tbz.ch --ssh-import gh:mc-b
sudo snap refresh

# LXD initialisieren ohne DNS, DHCP, Host: localhost, PW: password
cat <<%EOF% | sudo lxd init --preseed
config:
  core.https_address: '[::]:8443'
  core.trust_password: password
networks:
- config:
    ipv4.address: auto
    ipv6.address: auto
  description: ""
  name: lxdbr0
  type: ""
  project: default
storage_pools:
- config:
    size: 34GB
  description: ""
  name: default
  driver: zfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
projects: []
cluster: null
%EOF%

sudo lxc network set lxdbr0 dns.mode=none
sudo lxc network set lxdbr0 ipv4.dhcp=false
sudo lxc network set lxdbr0 ipv6.dhcp=false