tmux new-window -n "iptables" 'watch -n 1 "printf "   FILTER:\n\n" && iptables -L -v --line-numbers && printf "\n\n\n   NAT:\n\n" && iptables -t nat -L -v --line-numbers"'
tmux new-window -n "conntrack" 'watch -n 1 "cat -n /proc/net/nf_conntrack"'
#watch -n 5 'cat /proc/sys/net/ipv4/ip_forward'
tmux new-window -n "ip-route" 'watch -n 1 "(ip addr show eth0 && ip addr show eth1 && ip addr show eth2 && ip addr show wg0) | grep -vE "inet6|altname|link/ether|valid_lft""'
tmux split-window 'watch -n 1 "route -v"'

#debug wireguard
modprobe wireguard
echo module wireguard +p > /sys/kernel/debug/dynamic_debug/control
tmux new-window -n "wg-log" 'dmesg -wT | grep wireguard'
