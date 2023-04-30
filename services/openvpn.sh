#!/bin/bash
#   
#   Installiert und Aktiviert OpenVPN ueber WireGuard!
#

# wenn WireGuard installiert - Wireguard IP als MY_EXTERNAL_HOSTNAME Variable setzen
export MY_EXTERNAL_HOSTNAME=$(ip -f inet addr show wg0 | grep -Po 'inet \K[\d.]+')
[ "${MY_EXTERNAL_HOSTNAME}" == "" ] && { export MY_EXTERNAL_HOSTNAME=$(hostname -f); }

sudo apt-get install -y openvpn openssl

echo "Create keys"

[ -f /etc/openvpn/dh.pem ] || sudo openssl dhparam -out /etc/openvpn/dh.pem 2048
[ -f /etc/openvpn/key.pem ] || sudo openssl genrsa -out /etc/openvpn/key.pem 2048
sudo chmod 600 /etc/openvpn/key.pem
[ -f /etc/openvpn/csr.pem ] || sudo openssl req -new -key /etc/openvpn/key.pem -out /etc/openvpn/csr.pem -subj /CN=OpenVPN/
[ -f /etc/openvpn/cert.pem ] || sudo openssl x509 -req -in /etc/openvpn/csr.pem -out /etc/openvpn/cert.pem -signkey /etc/openvpn/key.pem -days 24855

###

echo "Create client configuration"
cat <<EOFCLIENT > ~/data/.ssh/$HOSTNAME.ovpn
client
nobind
comp-lzo
dev tap
<key>
$(sudo cat /etc/openvpn/key.pem)
</key>
<cert>
$(sudo cat /etc/openvpn/cert.pem)
</cert>
<ca>
$(sudo cat /etc/openvpn/cert.pem)
</ca>
<connection>
remote $MY_EXTERNAL_HOSTNAME 1194 tcp4
</connection>
EOFCLIENT

###

cat <<EOFUDP | sudo tee /etc/openvpn/server.conf
server-bridge
verb 3
duplicate-cn
comp-lzo
key key.pem
ca cert.pem
cert cert.pem
dh dh.pem
keepalive 10 60
persist-key
persist-tun
proto tcp
port 1194
dev tap1
status openvpn-status.log
log-append /var/log/openvpn.log
up "/bin/bash /etc/openvpn/bridge-start"
down "/bin/bash /etc/openvpn/bridge-stop"
EOFUDP

cat <<EOFBS | sudo tee /etc/openvpn/bridge-start
#!/bin/bash
br="br0"
tap=\$1

for t in \$tap; do
    brctl addif \$br \$t
done

for t in \$tap; do
    ifconfig \$t 0.0.0.0 promisc up
done

EOFBS

cat <<EOFBS | sudo tee /etc/openvpn/bridge-stop
#!/bin/bash
br="br0"
tap=\$1


EOFBS

### 
echo "Restart OpenVPN"
set +e
sudo systemctl daemon-reload
sudo systemctl stop openvpn
sudo systemctl start openvpn

