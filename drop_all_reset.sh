#!/bin/bash

# Define variables
WG_INTERFACE="wg0"
ALLOWED_PORTS="80,443"

echo "[+] Removing specific rules for wg0 and port restrictions..."

# Remove rules (adjust the parameters to match the insertion order)
iptables -D INPUT -i $WG_INTERFACE -p tcp -m multiport --dports $ALLOWED_PORTS -j ACCEPT
iptables -D INPUT ! -i $WG_INTERFACE -p tcp -m multiport --dports $ALLOWED_PORTS -j DROP
iptables -D INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "[+] Done. The previous restrictions on ports 80 and 443 have been lifted."
