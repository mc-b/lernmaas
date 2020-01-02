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
TEMPLATE="wg$((${PORT} - 51820))-template.conf"
CSV="wg$((${PORT} - 51820)).csv"
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
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>TBZ IT Server</title>
<link rel="shortcut icon" href="https://kubernetes.io/images/favicon.png">
<meta charset="utf-8" content="">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these

    <!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
    integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css"
    integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">
</head>
<body>
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

### Client ${host} (${HOST_KEY})
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
<tr><th>Private-Key</th><th>IP-Adresse</th></tr>
%EOF%

# CSV Datei
echo "Private-Key,IP-Adresse" >${CSV}

for client in {1..75}
do
    HOST_KEY=$(wg genkey)
    HOST_PUB=$(echo ${HOST_KEY} | wg pubkey)
    
    echo "<tr><td>${HOST_KEY}</td><td>192.168.${NET}.${counter}</td></tr>" >>${INDEX}
    
cat <<%EOF% >>${WG0}

### Client ${client} (${HOST_KEY})
[Peer]
PublicKey = ${HOST_PUB}
AllowedIPs = 192.168.${NET}.${counter}
%EOF%

    echo "${HOST_KEY},192.168.${NET}.${counter}" >>${CSV}
 
    counter=$((${counter} + 1))
    
done  

cat <<%EOF% >>${INDEX}
    </table>
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js" type="text/javascript"></script>
    <!-- Latest compiled and minified JavaScript -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
        integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"
        type="text/javascript"></script>
    <script>
                                        // strip / bei Wechsel Port
                                        document.addEventListener('click', function(event)
                                        {
                                                var target = event.target;
                                                if (target.tagName.toLowerCase() == 'a')
                                                {
                                                        var port = target.getAttribute('href').match(
                                                                        /^:(\d+)(.*)/);
                                                        if (port)
                                                        {
                                                                target.href = port[2];
                                                                target.port = port[1];
                                                        }
                                                }
                                        }, false);
                                </script>

</body>
</html>
%EOF%

cat <<%EOF% 

    Key Generierung erfolgreich
    ---------------------------
    
    ${WG0}          - WireGuard Konfigurationsdatei fuer Gateway
    ${TEMPLATE}     - WireGuard Template fuer Clients. Vervollstandigen mit IP-Adresse und Private-Key. Ablegen zu den Unterlagen
    ${CSV}          - Liste der Clients. Zum Bearbeiten mit Excel und Eintragen der Lernenden
    ${INDEX}        - HTML Seite mit Servern und Clients zum Ablegen auf dem Gateway
    HOSTNAME.conf   - Konfigurationsdateien fuer die VMs. In Verzeichnis /data/config/wireguard kopieren.
    
    
    WireGuard Interface auf dem Gateway aktiveren:
    systemctl enable wg-quick@wg$((${PORT} - 51820)).service
    systemctl start wg-quick@wg$((${PORT} - 51820)).service

%EOF%

