#!/bin/bash

ufw reset

sudo iptables --flush      # Flush all rules
sudo iptables --delete-chain  # Delete all chains
sudo iptables -X         # Another way to delete user-defined chains
sudo iptables -P INPUT ACCEPT   # Set default policies to ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

#...but keep forwarding
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv4.conf.all.forwarding=1
