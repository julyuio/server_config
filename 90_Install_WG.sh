#!/bin/bash

source conf

# wgx is a list of all the interfaces to create and its equivalent ports

wgx=("wg3")
ports=(51283)


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
fi

#Enable if you want Ipv6
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv4.conf.all.forwarding=1

#_______________Creating interfaces ___________________

for i in "${!wgx[@]}"; do
    	#echo "Index: $i, Wg: ${wgx[i]}, Ports:${ports[i]} "
	./create_wg_conf.sh ${wgx[i]} ${ports[i]}
done

