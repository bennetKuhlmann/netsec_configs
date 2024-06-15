#!/bin/bash
sudo -s

ip addr add 10.0.0.4/24 dev eth0
ip addr add 10.0.1.1/24 dev eth1


# enable ipv4 forwarding
sysctl -w net.ipv4.ip_forward=1

# ---------- FIREWALL -----------
# initial rules
for chain in "FORWARD INPUT OUTPUT"; do
  iptables --flush $chain
  iptables --policy $chain DROP
  iptables --append $chain --match state --state INVALID --jump DROP
done

# ---------- WIREGUARD ----------
apt install wireguard
wg genkey > /etc/wireguard/vpn.key
wg genkey < /etc/wireguard/vpn.key > /etc/wireguard/vpn.key.pub
WG_PRIV_KEY=$(cat /etc/wireguard/vpn.key)

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $WG_PRIV_KEY
Address = 10.0.3.1/32
ListenPort = 51820

[Peer]
PublicKey = <insert-public-key-from-remote>
AllowedIPs = 10.0.3.2/32
EOF

chmod 600 /etc/wireguard/vpn.key
chmod 644 /etc/wireguard/vpn.key.pub
chmod 600 /etc/wireguard/wg0.conf

iptables --table mangle --append PREROUTING --in-interface wg0 --jump MARK --set-mark 0x30
iptables --table nat --append POSTROUTING ! --out-interface wg0 --match mark --mark 0x30 --jump MASQUERADE