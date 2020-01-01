#!/bin/bash
#
#   Erstellt wg0.conf und die Keys fuer WireGuard Server und Clients
#

[ $# -lt 3 ] && { echo makekeys endpoint port pool; exit 1; }

### Argumente
ENDPOINT=$1:$2
PORT=$2
POOL=$3
NET=$((${PORT} - 51810))
WG0="wg$((${PORT} - 51820)).conf"
TEMPLATE="client$((${PORT} - 51820))-template.conf"
INDEX="${POOL}.html"
counter=11

# Server Keys
SERVER_KEY=$(wg genkey)
SERVER_PUB=$(echo ${SERVER_KEY} | wg pubkey)

cat <<%EOF% >${WG0}
[Interface]
Address = 192.168.${NET}.1
ListenPort = ${PORT}
PostUp = sysctl -w net.ipv4.ip_forward=1
PreDown = sysctl -w net.ipv4.ip_forward=0
PrivateKey = ${SERVER_KEY}
%EOF%

cat <<%EOF% >${TEMPLATE}
[Interface]
Address = <Replace IP>/24
PrivateKey = <Replace Key>

[Peer]
PublicKey = ${SERVER_PUB}
Endpoint = ${ENDPOINT}

AllowedIPs = 192.168.${NET}.0/24

# This is for if you're behind a NAT and
# want the connection to be kept alive.
PersistentKeepalive = 25
%EOF%

### VMs im MAAS Resource Pool

cat <<%EOF% >${INDEX}
<h3>Hosts</h3>
<table border="1" width="100%">
<tr><th>Hostname</th><th>IP-Adresse</th></tr>
%EOF%

for host in $(maas $PROFILE machines read | jq -r ".[] | select (.pool.name==\"${POOL}\") | .hostname" | sort)
do
    HOST_KEY=$(wg genkey)
    HOST_PUB=$(echo ${HOST_KEY} | wg pubkey)
    
cat <<%EOF% >${host}.conf
[Interface]
Address = 192.168.${NET}.${counter}/24
PrivateKey = ${HOST_KEY}

[Peer]
PublicKey = ${SERVER_PUB}
Endpoint = ${ENDPOINT}

AllowedIPs = 192.168.${NET}.0/24

# This is for if you're behind a NAT and
# want the connection to be kept alive.
PersistentKeepalive = 25
%EOF%

cat <<%EOF% >>${WG0}

### Client ${host}
[Peer]
PublicKey = ${HOST_PUB}
AllowedIPs = 192.168.${NET}.${counter}
%EOF%

    echo "<tr><td>${host}</td><td><a href=\"http://192.168.${NET}.${counter}\" target=\"_blank\">192.168.${NET}.${counter}</a></td><tr>" >>${INDEX}
 
    counter=$((${counter} + 1))
done

echo "</table>" >>${INDEX}

### Restliche Clients (drei pro Lernenden)

cat <<%EOF% >>${INDEX}
<h3>Clients</h3>
<table border="1" width="100%">
<tr><th>Key</th><th>IP-Adresse</th></tr>
%EOF%

for client in {1..75}
do
    HOST_KEY=$(wg genkey)
    HOST_PUB=$(echo ${HOST_KEY} | wg pubkey)
    
    echo "<tr><td>${HOST_KEY}</td><td>192.168.${NET}.${counter}</td></tr>" >>${INDEX}
    
cat <<%EOF% >>${WG0}

### Client ${client}
[Peer]
PublicKey = ${HOST_PUB}
AllowedIPs = 192.168.${NET}.${counter}
%EOF%
 
    counter=$((${counter} + 1))
    
done  

echo "</table>" >>${INDEX}  
    