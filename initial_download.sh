#!/bin/bash

apt update
apt install -y wireshark
apt install -y termshark

ifdown eth1