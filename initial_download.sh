#!/bin/bash
sudo -s

apt update
apt install -y wireshark
timedatectl set-ntp true

# down the last (internet able interface)
ifdown eth1