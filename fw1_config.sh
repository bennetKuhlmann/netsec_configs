#!/bin/bash
sudo -s

ip addr add 141.30.30.30/16 dev eth0
ip route add 0.0.0.0/0 via 141.30.30.30 dev eth0
ip addr add 10.0.0.1/24 dev eth1


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
# simple insecure port forwarding
#This rule redirects incoming UDP traffic on port 51820 to the internal IP address 10.0.0.4 on the same port.
iptables --table nat --append PREROUTING --protocol udp --dport 51820 --jump DNAT --to-destination 10.0.0.4:51820
#This rule modifies outgoing packets destined for 10.0.0.4 on port 51820 so that the source IP address is 
#replaced with the IP address of the outgoing interface. 
#This is useful for ensuring that the return traffic is correctly routed back to the original sender.
iptables --table nat --append POSTROUTING --destination 10.0.0.4 --protocol udp --dport 51820 --jump MASQUERADE