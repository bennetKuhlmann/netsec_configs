#!/bin/bash
sudo -s

ip addr add 141.30.30.30/16 dev eth0
ip route add 200.200.200.200/32 dev eth0
ip route add 210.210.210.210/32 dev eth0
ip addr add 10.0.0.1/24 dev eth1


# enable ipv4 forwarding
sysctl -w net.ipv4.ip_forward=1

# ---------- FIREWALL -----------
# initial rules
for chain in "FORWARD INPUT OUTPUT"; do
  iptables --flush $chain
  iptables --policy $chain DROP
  iptables --append $chain --match conntrack --ctstate INVALID --jump DROP
done

# ---------- WIREGUARD ----------
# simple insecure port forwarding
#This rule redirects incoming UDP traffic on port 51820 to the internal IP address 10.0.0.4 on the same port.
iptables --table nat --append PREROUTING --in-interface eth0 --destination 141.30.30.30 --protocol udp --sport 51821 --dport 51820 --jump DNAT --to-destination 10.0.0.4:51820

iptables --append FORWARD --in-interface eth0 --out-interface eth1 --destination 10.0.0.4 --protocol udp --dport 51820 --match conntrack --ctstate NEW,ESTABLISHED --jump ACCEPT
iptables --append FORWARD --in-interface eth1 --out-interface eth0 --source 10.0.0.4 --protocol udp --sport 51820 --match conntrack --ctstate ESTABLISHED --jump ACCEPT

#This rule modifies outgoing packets destined for 10.0.0.4 on port 51820 so that the source IP address is 
#replaced with the IP address of the outgoing interface. 
#This is useful for ensuring that the return traffic is correctly routed back to the original sender.
iptables --table nat --append POSTROUTING --out-interface eth1 --destination 10.0.0.4 --protocol udp --sport 51821 --dport 51820 --jump MASQUERADE