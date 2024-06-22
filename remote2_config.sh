#!/bin/bash

ip addr add 210.210.210.210/32 dev eth0
ip route add 141.30.30.30/32 dev eth0

# ---------- WIREGUARD ----------
wg genkey > /etc/wireguard/remote.key
wg genkey < /etc/wireguard/remote.key > /etc/wireguard/remote.key.pub
WG_PRIV_KEY=$(cat /etc/wireguard/remote.key)

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $WG_PRIV_KEY
Address = 10.0.3.3/32
ListenPort = 51821

[Peer]
PublicKey = <insert-public-key-from-vpn-server>
Endpoint = 141.30.30.30:51820
AllowedIPs = 10.0.1.0/24
EOF
# also maybe PersistentKeepalive

chmod 600 /etc/wireguard/remote.key
chmod 644 /etc/wireguard/remote.key.pub
chmod 600 /etc/wireguard/wg0.conf


