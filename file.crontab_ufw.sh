#!/bin/bash

#_________Config__________________
tempdir="/july/iplog"
tempfile="$tempdir/temp_ips.txt"
ip_block="$tempdir/block_list.txt"
ip_allow="$tempdir/allow_list.txt"

if [ ! -d "$tempdir" ]; then
    mkdir -p $tempdir
fi


#Config here your ports that you want keep open
ports=(22 80 443 53)

#___________ Reset all__________

echo "Resetting UFW..."
sudo ufw disable
sudo ufw --force reset

#____________ Block IPs___________
# Getting IPs from IPsum
IP_FILE="/tmp/UFW_$(date +%d-%m-%Y).txt"
#touch $IP_FILE
echo "Getting badboy IP list from IPsum..."
curl https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt  | grep -v "#" | grep -v -E "\s[1-2]$" | cut -f 1 > $IP_FILE

#Compress the IP list into IP + ranges and subnets
IP_FILE_DENY="$IP_FILE.deny"
python3 kompress_ipv4.py $IP_FILE > $IP_FILE_DENY
IP_FILE=$IP_FILE_DENY

# Count the total number of IP addresses
total_ips=$(wc -l < "$IP_FILE")
current_ip=0
time_per_100=54 #sec
total_time=$((total_ips/100*time_per_100/60)) #min

echo "continuing in 10 sec..."
sleep 10
                if [ ! -f "$IP_FILE" ]; then
                        echo "File $IP_FILE not found!"
                        exit 1
                fi

                while IFS= read -r ip; do
                        current_ip=$((current_ip + 1))
                        ufw deny from $ip > /dev/null 2>&1
                        echo -n "Progress: $current_ip out of $total_ips IPs"$'\r'
                done < "$IP_FILE"
rm $IP_FILE

#____________ Allow IPs___________
echo "Setting internal IP rules...allowing.."
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

#______________ Allow Google ______________
echo"allowing google IPs..."
#Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq is not installed. Installing jq..."
    apt-get install -y jq
fi

echo "Getting Google IPs..."
tmp_google_ips="/tmp/google_extracted_ips.txt"

#google bots
json_file="/tmp/googlebot.json"
url="https://developers.google.com/static/search/apis/ipranges/googlebot.json"
curl -o "$json_file" "$url"
jq -r '.prefixes[].ipv4Prefix' $json_file | grep -v "null" > $tmp_google_ips
jq -r '.prefixes[].ipv6Prefix' $json_file | grep -v "null" > "$tmp_google_ips.IPv6"
rm $json_file

#special google ai crawlers
json_file="/tmp/special-crawlers.json"
url="https://developers.google.com/static/search/apis/ipranges/special-crawlers.json"
curl -o "$json_file" "$url"
jq -r '.prefixes[].ipv4Prefix' $json_file | grep -v "null" >> $tmp_google_ips
jq -r '.prefixes[].ipv6Prefix' $json_file | grep -v "null" >> "$tmp_google_ips.IPv6"
rm $json_file

#From here process only IPv4 ips
#TODO: future develop same scripts for IPv6
#Filter IPv4 Ips withoud CIDR and "compress" ranges reducing the IPs from 240 to 20 or so
allowed_ips="$tmp_google_ips.IPv4.allowed"
google_ipv4="$tmp_google_ips.IPv4"

#Extract all IPv4
cat $tmp_google_ips | sort -u | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}+' > $google_ipv4
python3 ./kompress_ipv4.py $google_ipv4 > $allowed_ips

# Count the total number of IP addresses
total_ips=$(wc -l < $allowed_ips)
current_ip=0
total_time=$((total_ips/100*time_per_100/60)) #min
echo -e "Allowing Google IPs, duration time: ${IGreen}$total_time min${Color_Off}"

#Start reading allowed_ips and allowing IPs
while IFS= read -r ip
do
  current_ip=$((current_ip + 1))
  ufw allow from $ip > /dev/null 2>&1
  echo -n "Progress: $current_ip out of $total_ips IPs"$'\r'
done < $allowed_ips

#______________ Bing IPs___________________
echo "allowing Bing Ips..."
#For Bing is much more easy as there are just a few IPs and they do not repeat, thus no need to kompress

bing_ips="/tmp/bing_ips"
url="https://raw.githubusercontent.com/AnTheMaker/GoodBots/refs/heads/main/iplists/bingbot.ips"
curl $url > $bing_ips
allowed_ips=$bing_ips

# Count the total number of IP addresses
total_ips=$(wc -l < $allowed_ips)
current_ip=0
total_time=$((total_ips/100*time_per_100/60)) #min
echo -e "Allowing Bing IPs, duration time: ${IGreen}$total_time min${Color_Off}"

#Start reading allowed_ips and allowing IPs
while IFS= read -r ip
do
  current_ip=$((current_ip + 1))
  ufw allow from $ip > /dev/null 2>&1
  echo -n "Progress: $current_ip out of $total_ips IPs"$'\r'
done < $allowed_ips


#__________Clean up______________

ufw --force enable
rm /tmp/UFW*
rm /tmp/google*
rm /tmp/bing*

