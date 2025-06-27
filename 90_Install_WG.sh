#!/bin/bash

source conf

# wgx is a list of all the interfaces to create and its equivalent ports

wgx=("wg1")
ports=(51281)


#__________ Installing or configuring WG  ___________________
if command -v wg >/dev/null 2>&1; then
   	echo " "
        echo -e "${IGreen} Configuring WG... ${Color_Off} "
        sleep 2
        echo " "
else
    	echo " "
	echo -e "${IGreen} Installing  WG... ${Color_Off} "
	sleep 2
	echo " "

	# installing wireguard
	apt install wireguard -y
	apt install qrencode -y
fi

#Enable if you want Ipv6
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv4.conf.all.forwarding=1

# Define sysctl configuration file
SYSCTL_CONF="/etc/sysctl.conf"

# Backup the current sysctl.conf file
cp "$SYSCTL_CONF" "$SYSCTL_CONF.bak"

# Add forwarding settings if not already present
grep -qxF "net.ipv6.conf.all.forwarding=1" "$SYSCTL_CONF" || echo "net.ipv6.conf.all.forwarding=1" >> "$SYSCTL_CONF"
grep -qxF "net.ipv4.conf.all.forwarding=1" "$SYSCTL_CONF" || echo "net.ipv4.conf.all.forwarding=1" >> "$SYSCTL_CONF"

# Apply the changes
sysctl -p

echo "IPv4 and IPv6 forwarding enabled and made persistent!"


#_______________Creating interfaces ___________________

for i in "${!wgx[@]}"; do
    	#echo "Index: $i, Wg: ${wgx[i]}, Ports:${ports[i]} "
	./create_wg_conf.sh ${wgx[i]} ${ports[i]}
done

echo "-------------------- Note ---------------------------"
echo "Usually if the configuration does not work and you have 0B sent then usually it is an issue witht he Firewall. If only 92B are recieved then it is an issue with IP forwarding, either check forwarding rules or reset iptables. If recieving kB of data , then all is ok."
echo ""
sleep 2
echo "Done... "
