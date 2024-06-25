#!/bin/bash
ip addr add 210.210.210.210/32 dev eth0
ip route add 141.30.30.30/32 dev eth0

# ---------- WIREGUARD ----------
wg genkey > /etc/wireguard/remote.key
wg pubkey < /etc/wireguard/remote.key > /etc/wireguard/remote.key.pub
WG_PRIV_KEY=$(cat /etc/wireguard/remote.key)

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $WG_PRIV_KEY
Address = 10.0.3.3/32
ListenPort = 51821

[Peer]
PublicKey = <insert-public-key-from-vpn-server>
Endpoint = 141.30.30.30:51820
AllowedIPs = 10.0.1.0/32, 10.0.1.2/31, 10.0.1.4/30, 10.0.1.8/29, 10.0.1.16/28, 10.0.1.32/27, 10.0.1.64/26, 10.0.1.128/25
PersistentKeepalive = 25
EOF
# also maybe PersistentKeepalive

chmod 600 /etc/wireguard/remote.key
chmod 644 /etc/wireguard/remote.key.pub
chmod 600 /etc/wireguard/wg0.conf


