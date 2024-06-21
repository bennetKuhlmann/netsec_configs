ip a add 10.0.0.11/24 dev eth0
ifconfig eth1 down
ip route add 0.0.0.0/0 via 10.0.0.1/24

apt update
apt install -y bind9 bind9utils bind9-doc dnsutils

# copy all files to needed postion
# /etc/bind/...
# /var/lib/bind/... <--- zone file

# add the following line to all VMs at /etc/resolv.conf
# nameserver 10.0.0.11

systemctl start named
