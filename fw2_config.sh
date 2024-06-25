#!/bin/bash
ip addr add 10.0.0.4/24 dev eth0
ip addr add 10.0.1.1/24 dev eth1


# enable ipv4 forwarding
sysctl -w net.ipv4.ip_forward=1

# ---------- FIREWALL -----------
# initial rules
for chain in FORWARD INPUT OUTPUT; do
  iptables --flush $chain
  iptables --policy $chain DROP
  iptables --append $chain --match conntrack --ctstate INVALID --jump DROP
done

# ---------- WIREGUARD ----------
wg genkey > /etc/wireguard/vpn.key
wg pubkey < /etc/wireguard/vpn.key > /etc/wireguard/vpn.key.pub
WG_PRIV_KEY=$(cat /etc/wireguard/vpn.key)

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $WG_PRIV_KEY
Address = 10.0.3.1/32
ListenPort = 51820

[Peer]
PublicKey = <insert-public-key-from-remote>
AllowedIPs = 10.0.3.2/32

[Peer]
PublicKey = <insert-public-key-from-remote>
AllowedIPs = 10.0.3.3/32
EOF

chmod 600 /etc/wireguard/vpn.key
chmod 644 /etc/wireguard/vpn.key.pub
chmod 600 /etc/wireguard/wg0.conf

# fw1 can communicate to the fw2 wg-port
iptables --append INPUT --source 10.0.0.1 --destination 10.0.0.4 --protocol udp --dport 51820 --in-interface eth0 --match conntrack --ctstate NEW,ESTABLISHED --jump ACCEPT

# all wg-generated packets are marked
iptables --table mangle --append PREROUTING --in-interface wg0 --jump MARK --set-mark 0x30

# what packets are allowed to flow 
# - from wg0 interface (formerly coming from fw1 to wg-port)
# - to eth1
iptables --append FORWARD --in-interface wg0 --out-interface eth1 --source 10.0.3.1 --destination 10.0.1.0/24 --jump DROP
iptables --append FORWARD --in-interface wg0 --out-interface eth1 --source 10.0.3.0/24 --destination 10.0.1.1 --jump DROP
iptables --append FORWARD --in-interface wg0 --out-interface eth1 --source 10.0.3.0/24 --destination 10.0.1.0/24 --match conntrack --ctstate NEW,ESTABLISHED --jump ACCEPT

# Nating all packages that came from wg and are now going to lan
iptables --table nat --append POSTROUTING --out-interface eth1 --match mark --mark 0x30 --jump MASQUERADE

# what packets are allowed to flow from eth1 to wg
iptables --append FORWARD --in-interface eth1 --out-interface wg0 --source 10.0.1.1 --destination 10.0.3.0/24 --jump DROP
iptables --append FORWARD --in-interface eth1 --out-interface wg0 --source 10.0.1.0/24 --destination 10.0.3.1 --jump DROP
iptables --append FORWARD --in-interface eth1 --out-interface wg0 --source 10.0.1.0/24 --destination 10.0.3.0/24 --match conntrack --ctstate ESTABLISHED --jump ACCEPT

# fw2 can respond to fw1 from wg-port
iptables --append OUTPUT --source 10.0.0.4 --destination 10.0.0.1 --protocol udp --sport 51820 --out-interface eth0 --match conntrack --ctstate ESTABLISHED --jump ACCEPT
