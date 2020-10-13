#!/bin/bash
#
# 	Installiert cr-o

set -o xtrace

export VERSION=1.19
export OS=xUbuntu_20.04

sudo modprobe overlay
sudo modprobe br_netfilter

# Set up required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

curl -s -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | sudo apt-key add -
curl -s -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

sudo apt-get update
sudo apt-get install -y cri-o cri-o-runc

sudo systemctl daemon-reload
sudo systemctl start crio

## k8s configuration
export ADDR=$(ip -f inet addr show wg0 | grep -Po 'inet \K[\d.]+')
[ "${ADDR}" == "" ] && { export ADDR=$(hostname -I | cut -d ' ' -f 1); }

cat <<%EOF% | envsubst | tee kubeadm.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  criSocket: /var/run/crio/crio.sock
  name: $(hostname -f)
  kubeletExtraArgs:
    cgroup-driver: "systemd"    
  ignorePreflightErrors:
  - IsPrivilegedUser      
localAPIEndpoint:
  advertiseAddress: ${ADDR}
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
networking:
  serviceSubnet: "10.96.0.0/12"
  podSubnet: "10.244.0.0/16"
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
%EOF%

