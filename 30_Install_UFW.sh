#!/bin/bash

source conf

#______________Check if python is installed____________

#Python is needed to kompress the IP file into ranges
if command -v python3 &> /dev/null
then
    echo ""
else
    echo "Python 3 is not installed."
    exit 1
fi

#_______________ Install & Configure UFW _______________
echo " "
echo -e "${IGreen} Installing UFW ... ${Color_Off} "
sleep 2
echo " "

apt install ufw -y

#_____________________ Internal Rules __________________
echo "Adding Intenal Rules..." 
#Setting internal rules
ufw allow from 10.0.0.0/24  > /dev/null 2>&1
ufw allow from 172.16.0.0/12 > /dev/null 2>&1
ufw allow 80 > /dev/null 2>&1
ufw allow 22 > /dev/null 2>&1
ufw allow 53 > /dev/null 2>&1
ufw allow 443 > /dev/null 2>&1
ufw allow 6195 > /dev/null 2>&1
# Allowing IPs from Let's Encrypt SSL
ufw allow from 52.38.45.221 > /dev/null 2>&1
ufw allow from 13.212.180.206 > /dev/null 2>&1


#_____________________ ALLOW___________________________

# Google IPs

#Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq is not installed. Installing jq..."
    apt-get install -y jq
fi

echo "Getting Google IPs..."
tmp_google_ips="/tmp/google_extracted_ips.txt"

json_file="/tmp/googlebot.json"
url="https://developers.google.com/static/search/apis/ipranges/googlebot.json"
curl -o "$json_file" "$url"
jq -r '.prefixes[].ipv4Prefix' $json_file | grep -v "null" > $tmp_google_ips
jq -r '.prefixes[].ipv6Prefix' $json_file | grep -v "null" > "$tmp_google_ips.IPv6"
rm $json_file

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

#Bing IPs

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

#______________________ DENY __________________________
# Getting IPs from IPsum
IP_FILE="/tmp/UFW_$(date +%d-%m-%Y).txt"
#touch $IP_FILE
echo "Getting IP list from IPsum..."
curl https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt  | grep -v "#" | grep -v -E "\s[1-2]$" | cut -f 1 > $IP_FILE

#TODO: Get IPs from 77 server

#Compress the IP list into IP + ranges and subnets
IP_FILE_DENY="$IP_FILE.deny"
python3 kompress_ipv4.py $IP_FILE > $IP_FILE_DENY
IP_FILE=$IP_FILE_DENY

echo "$IP_FILE"

# Count the total number of IP addresses
total_ips=$(wc -l < "$IP_FILE")
current_ip=0
time_per_100=54 #sec
total_time=$((total_ips/100*time_per_100/60)) #min

echo " "
echo -e -n "$total_ips${IRed} IPs to be added It's going to take ${IGreen} $total_time min${Color_Off} ...continue ? (y/n) "
read response
        if [ "$response" = "y" ] || [ -z "$response" ]; then
            sleep 4
            # Check if the file exists
		if [ ! -f "$IP_FILE" ]; then
  			echo "File $IP_FILE not found!"
  			exit 1
		fi
		# Read the file line by line
		while IFS= read -r ip; do
 			current_ip=$((current_ip + 1))
 			ufw deny from $ip > /dev/null 2>&1
 			echo -n "Progress: $current_ip out of $total_ips IPs"$'\r'
		done < "$IP_FILE"
        else
            echo "Please add them manually... "
        fi
rm $IP_FILE

#_________ cleanup __________

# icmp does not work for whatever reason
#ufw deny proto icmp from any to any

#sudo ufw logging on
ufw logging off
rm output.txt

# Add this if you get atacks on 6195 port. it limits
#sudo ufw limit 6195/tcp


#-------- End and Enable -----------
echo -e "${IRed}"
ufw enable
echo -e "${Color_Off}..."

