#!/bin/bash

source conf

if [ "$#" -eq 2 ]; then
    echo "Interface $1 on port $2"
else
    echo "Usage: $0 wgx port"
    exit 1
fi

int=$1
port=$2
int_n=$(echo "$int" | grep -o '[0-9]*')

filename="/etc/wireguard/$int.conf"
if [ -e "$filename" ]; then
    echo "The file '$filename' already exists."
    read -p "Are you sure you want to proceed? (yes/no): " response
    if [ "$response" == "yes" ] || [ -z "$response" ]; then
        echo "Proceeding..."
    else
        echo "Operation canceled."
	exit 1
    fi
else
    echo "Creating '$filename'"
fi

echo "172.16.$int_n.0/24"

#______________ Configuration and Keys___________
echo -e "${IRed} Creating WG keys in 10... ${Color_Off} "
counter=0
while [ $counter -lt 10 ]; do
    counter=$((counter + 1))
    echo -n -e "${IRed}... $counter ${Color_Off}"$'\r'
    sleep 1
done

#Gen Keys
wg genkey | tee privatekey_server | wg pubkey > publickey_server
wg genkey | tee privatekey_client | wg pubkey > publickey_client

#Read them and delete
read -r pk_server < privatekey_server
read -r pub_server < publickey_server
read -r pk_client < privatekey_client
read -r pub_client < publickey_client
rm privatekey_server publickey_server privatekey_client publickey_client

eth=$(ip -o addr | awk '!/^[0-9]*: ?lo|link\/ether/ {gsub("/", " "); print $2}' | head -n 1)    #ethernet
wgip=$(ip -o addr | awk '!/^[0-9]*: ?lo|link\/ether/ {gsub("/", " "); print $4}' | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n 1)
wg_server="wg.server"


#________________ Server Configuration File___________________
echo "[Interface]" > $wg_server
echo "Address = 172.16.$int_n.1/24">> $wg_server
echo "PrivateKey = $pk_server ">> $wg_server
echo "PostUp = iptables -A FORWARD -i $int -j ACCEPT; iptables -t nat -A POSTROUTING -o $eth -j MASQUERADE;">> $wg_server
echo "PostDown = iptables -D FORWARD -i $int -j ACCEPT; iptables -t nat -D POSTROUTING -o $eth -j MASQUERADE;">> $wg_server
echo "ListenPort = $port">> $wg_server
echo "#DNS = 1.1.1.1">> $wg_server
echo "">> $wg_server

echo "[Peer]">> $wg_server
echo "PublicKey = $pub_client">> $wg_server
echo "AllowedIPs = 172.16.$int_n.0/24">> $wg_server

#copying the server file to wireguard
cp $wg_server "/etc/wireguard/$int.conf"
rm $wg_server

wg-quick down $int
wg-quick up $int

#adding wg as a service
systemctl enable "wg-quick@$int.service"

#enable UFW
ufw allow $port 

wg_client="/tmp/wg$int_n.client"
#________________ Client Configuration File_________________
echo "_________________________________"
echo -e "Please copy this to the client and enable port${IRed} $port in the firewall: ${Color_Off}"
echo ""

echo "[Interface]" > $wg_client
echo "PrivateKey = $pk_client">>$wg_client
echo "Address = 172.16.$int_n.2/24">>$wg_client
echo "DNS = 1.1.1.1">>$wg_client
echo "">>$wg_client
echo "[Peer]">>$wg_client
echo "PublicKey = $pub_server">>$wg_client
echo "AllowedIPs = 0.0.0.0/0, ::/0">>$wg_client
echo "Endpoint = $wgip:$port">>$wg_client
echo ""
echo ""

#__________________ QR Encode for easy mobile deployment______________
if ! command -v qrencode >/dev/null 2>&1; then
    echo -e "${IRed}QR encode is not installed${Color_Off}"
else
    qrencode -t ansiutf8 < $wg_client
fi

cat $wg_client
rm $wg_client
