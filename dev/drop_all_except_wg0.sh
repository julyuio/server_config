#!/bin/bash

# Define variables
WG_INTERFACE="wg0"
ALLOWED_PORTS="80,443"


echo "[+] Allowing ESTABLISHED and RELATED connections..."
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "[+] Allowing HTTP/HTTPS on $WG_INTERFACE..."
iptables -A INPUT -i $WG_INTERFACE -p tcp -m multiport --dports $ALLOWED_PORTS -j ACCEPT

echo "[+] Blocking HTTP/HTTPS on all other interfaces..."
iptables -A INPUT ! -i $WG_INTERFACE -p tcp -m multiport --dports $ALLOWED_PORTS -j DROP

echo "[+] Done. iptables rules are in place."
