#!/bin/bash

sudo -s

apt update
apt install wireshark

ip link set eth1 down
ip addr flush dev eth1
sed -i '/eth1/d' /etc/network/interfaces
rm /var/lib/dhcp/dhclient.eth1.leases
ip route del default via <gateway-ip> dev eth1
ip route flush dev eth1
#sed -i '/<dns-server-ip>/d' /etc/resolv.conf