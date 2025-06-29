#!/bin/bash

#source conf

#_________Config__________________
CRONDIR="/july/crontab"
TMPFILE="$CRONDIR/temp_ips.txt"
IPBLOCK="$CRONDIR/block_list.txt"
IPALLOW="$CRONDIR/allow_list.txt"
STATFILE="$CRONDIR/stats.txt"
IPLOGFILE="$CRONDIR/log"

if [ ! -d "$CRONDIR" ]; then
    mkdir -p $CRONDIR
fi

touch $TMPFILE

# Allow Ports list
ports=(22 80 443 53)

#___________ Extract IPs__________
echo "Adding  unsecured ssh tries..."
sudo journalctl --since="1 days ago" -u ssh | grep -e "banner exchange" -e "fail" |grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' >> $TMPFILE
stat_ssh_tries=$(wc -l < $TMPFILE)

echo "Extracting IPs excluding HTTP access codes: 40x and 50x"
awk '$9 ~ /^40[0-9]/ || $9 ~ /^50[0-9]/  {print $1}'  /var/log/nginx/access.log | sort -ur  | grep -v '10.0.0' | grep -v '172.16.0' >> $TMPFILE
stat_total=$(wc -l < $TMPFILE)

#____________ Block IPs___________
# Read the file line by line
echo "Blocking IPs.."
while IFS= read -r line
do
  #echo "Denying IP: $line"
  ufw deny from "$line" > /dev/null 2>&1
done < "$TMPFILE"

#____________ Allow IPs___________
echo "Allowing own IPs and ports..."
#Setting internal rules
ufw allow from 10.0.0.0/12  > /dev/null 2>&1
ufw allow from 172.16.0.0/12 > /dev/null 2>&1
# Allowing IPs from Let's Encrypt SSL
ufw allow from 52.38.45.221 > /dev/null 2>&1
ufw allow from 13.212.180.206 > /dev/null 2>&1

# Loop through each port and allow it with UFW
for port in "${ports[@]}"; do
    sudo ufw allow "$port" > /dev/null 2>&1
done

# Read each ip from allow file
while IFS= read -r line
do
  #echo "Allowing IP: $line"
  ufw allow from "$line" > /dev/null 2>&1
done < "$IPALLOW"

#________ Statistics_________

#actually the nginx stat are the total minus the ssh tries at the begining
stat_nginx=$(expr $stat_total - $stat_ssh_tries)
datetime=$(date +"%d-%m-%Y %H:%M:%S")
stat_iptable=$(iptables -L | wc -l)

if [ ! -f "$STATFILE" ]; then
    echo "Date Time Total SSH Nginx IPtables" > $STATFILE
fi

echo "$datetime Total:$stat_total SSH:$stat_ssh_tries Nginx:$stat_nginx IPtables:$stat_iptable"
echo "$datetime $stat_total $stat_ssh_tries $stat_nginx $stat_iptable" >> $STATFILE

#create and save the ips in a day file in log directory
if [ ! -d "$IPLOGFILE" ]; then
    mkdir -p $IPLOGFILE
fi
logfile="$IPLOGFILE/blocked_$(date +%d-%m-%Y).txt"
cat $TMPFILE > $logfile


#__________Clean up______________
ufw reload

#Adding today's IPs to the the main ip file
cat $TMPFILE >> $IPBLOCK
rm $TMPFILE
echo "Done"
echo ""
