#!/bin/bash
sudo -s

apt update
apt install -y wireshark
ntpdate pool.ntp.org

git clone https://www.github.com/bennetKuhlmann/netsec_configs

# down the last (internet able interface)
ifdown eth1

# tmux
tmux
tmux set-option prefix C-b
tmux set-option mouse on