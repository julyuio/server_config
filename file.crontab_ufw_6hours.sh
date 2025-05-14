#!/bin/bash

#_________Config__________________
tempdir="/july/iplog"
tempfile="$tempdir/temp_ips.txt"
ip_block="$tempdir/block_list.txt"
ip_allow="$tempdir/allow_list.txt"

if [ ! -d "$tempdir" ]; then
    mkdir -p $tempdir
fi

touch $tempfile

# Ports list, 6195 is the ssh and 5128x are the wg ports
ports=(22 80 443 53 6195 51280 51281 51282 51283 51284 51285 51286 51287 51288 51289 51290)

#___________ Extract IPs__________
echo "Adding  unsecured ssh tries..."
sudo journalctl --since="1 days ago" -u ssh | grep -e "banner exchange" -e "fail" |grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' >> $tempfile

echo "Extracting IPs excluding HTTP access codes: 40x and 50x"
awk '$9 ~ /^40[0-9]/ || $9 ~ /^50[0-9]/  {print $1}'  /var/log/nginx/access.log | sort -ur  | grep -v '10.0.0' | grep -v '172.16.0' >> $tempfile

#____________ Block IPs___________
# Read the file line by line
while IFS= read -r line
do
  #echo "Denying IP: $line"
  ufw deny from "$line" > /dev/null 2>&1
done < "$tempfile"

#____________ Allow IPs___________

#Setting internal rules
ufw allow from 10.0.0.0/12  > /dev/null 2>&1
ufw allow from 172.16.0.0/12 > /dev/null 2>&1
ufw allow from 77.68.2.183 > /dev/null 2>&1
# Allowing IPs from Let's Encrypt SSL
ufw allow from 52.38.45.221 > /dev/null 2>&1
ufw allow from 13.212.180.206 > /dev/null 2>&1

ports=(22 80 443 53 6195 51280 51281 51282 51283 51284 51285 51286 51287 51288 51289 51290)

# Loop through each port and allow it with UFW
for port in "${ports[@]}"; do
    sudo ufw allow "$port" > /dev/null 2>&1
done

# Read each ip from allow file
while IFS= read -r line
do
  #echo "Allowing IP: $line"
  ufw allow from "$line" > /dev/null 2>&1
done < "$ip_allow"

#__________Clean up______________
ufw reload

#Adding today's IPs to the the main ip file
cat $tempfile >> $ip_block
rm $tempfile

