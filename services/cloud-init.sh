#!/bin/bash
#
#   Zentraler Script wird von cloud-init aufgerufen.
#   
#   Installiert anhand lernmaas/config.yaml Software in die VMs.
#
#   Zuerst werden die Services durchlaufen und dann die zusaetzlichen Scripts
#

# einfacher YAML Parser von https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
function parse_yaml 
{
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=%s\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

################### YAML datei auswerten ###################

# config.yaml parsen und als config_xxxx Umgebungsvariablen setzen
export HOST=$(hostname | cut -d- -f 1)
for e in $(eval parse_yaml config.yaml | grep "^${HOST}" | sed "s/^${HOST}/config/")
do
    export $e
done

################### Services ###################

# NFS Abhandlung - wenn ohne NFS gearbeitet wird data etc. Verzeichnis anlegen
if [ "${config_services_nfs}" == "true" ] 
then
    bash -x services/nfs.sh
else
    mkdir -p config templates data
    chmod 777 data
fi

# Sicherstellen, dass /data fuer Kubernetes existiert      
sudo ln -s $HOME/data /data 

# Wireguard
[ "${config_services_wireguard}" != "" ] && { bash -x services/wireguard.sh ${config_services_wireguard} ${HOST}; }

# Zusaetzliche SSH Keys
[ "${config_services_ssh}" != "" ] && { bash -x services/sshkeys.sh ${config_services_ssh} ${HOST}; }

# Docker oder cri-o, container
[ "${config_services_docker}" == "true" ] && { bash -x services/docker.sh; }
[ "${config_services_docker}" == "cri-o" ] && { bash -x services/cri-o.sh; }
[ "${config_services_docker}" == "containerd" ] && { bash -x services/containerd.sh; }

# Kubernetes
if [ "${config_services_k8s}" == "minimal" ] 
then
    bash -x services/k8sbase.sh
    bash -x services/k8smaster.sh
    [ -f doc/${HOST}.md ] && { bash -x services/k8swebui.sh doc/${HOST}.md ${config_services_k8s}; } || { bash -x services/k8swebui.sh doc/intro.md ${config_services_k8s}; } 
fi

if [ "${config_services_k8s}" == "master" ] 
then
    bash -x services/k8sbase.sh
    bash -x services/k8smaster.sh
    bash -x services/k8saddons.sh
    [ -f doc/${HOST}.md ] && { bash -x services/k8swebui.sh doc/${HOST}.md ${config_services_k8s}; } || { bash -x services/k8swebui.sh doc/intro.md ${config_services_k8s}; } 
fi

if [ "${config_services_k8s}" == "worker" ] 
then
    bash -x services/k8sbase.sh
    bash -x services/k8sjoin.sh
fi

if [ "${config_services_k8s}" == "k3s" ] 
then
    bash -x services/k3s.sh
fi

if [ "${config_services_k8s}" == "microk8s" ]
then
    bash -x services/microk8s.sh ${config_services_k8s}
fi

if [ "${config_services_k8s}" == "rancher" ] 
then
    bash -x services/rancher.sh
fi

if [ "${config_services_k8s}" == "openshift" ] 
then
    bash -x services/openshift.sh
fi

# Samba
[ "${config_services_samba}" == "true" ] && { bash -x services/samba.sh; }

################### Repositories ###################

for repo in $(echo ${config_repositories} | tr ',' ' ')
do
    bash -x services/repository.sh ${repo}
done

# Repositories aus Description von Node oder Resource Pool
if [ -f repositories ]
then
    for repo in $(cat repositories)
    do
        bash -x services/repository.sh ${repo}
    done
fi    

################### Scripts ###################

for script in $(echo ${config_scripts} | tr ',' ' ')
do
    bash -x scripts/${script}
done

################### Firewall ###################

[ "${config_services_firewall}" == "true" ] && { bash -x services/ufw.sh; }

################### unmount ../config Verzeichnis - aus Sicherheitsgruenden ###################

sudo umount /home/ubuntu/config
rmdir /home/ubuntu/config

exit 0
