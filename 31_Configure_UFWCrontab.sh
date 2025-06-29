#!/bin/bash

source conf

CRONDIR="/july/crontab"

#_______________ Install & Configure UFW _______________
echo " "
echo -e "${IGreen} Configuring crontab ufw  ... ${Color_Off} "
echo " "
sleep 2


#______________Check if python & jq are  installed____________

#Python is needed to kompress the IP file into ranges
if command -v python3 &> /dev/null
then
    echo ""
else
    echo "Python 3 is not installed."
    exit 1
fi

#Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq is not installed. Installing jq..."
    apt-get install -y jq
fi

apt install iptables-persistant -y
systemctl enable netfilter-persistent

#apt install ipset
#________________ Create dir and copy files____________

echo "[+] Creating dirs and copying files..."
if [ ! -d "$CRONDIR" ]; then
    mkdir -p $CRONDIR
fi

cp file.crontab_ufw_monthly.sh  $CRONDIR/crontab_ufw_monthly.sh
cp file.crontab_ufw_daily.sh $CRONDIR/crontab_ufw_daily.sh
touch $CRONDIR/allow_list.txt
touch $CRONDIR/ block_list.txt
cp conf $CRONDIR/conf
cp kompress_ipv4.py $CRONDIR/kompress_ipv4.py
chmod 775 $CRONDIR/crontab_ufw_monthly.sh
chmod 775 $CRONDIR/crontab_ufw_daily.sh

#echo -e " Run command :${IRed} sudo crontab -e ${Color_Off} and copy the folowing line at the end of the file: "
#echo -e " ${IGreen}45  23  *   *   *    $CRONDIR/crontab_ufw_daily.sh${Color_Off}"
#echo -e " ${IGreen}45  23  1   *   *    $CRONDIR/crontab_ufw_monthly.sh${Color_Off}"
#echo " "

echo "[+] Adding to crontab..."
(crontab -l 2>/dev/null; echo "45  23  *  *  * $CRONDIR/crontab_ufw_daily.sh") | crontab -
(crontab -l 2>/dev/null; echo "45  23  1  *  * $CRONDIR/crontab_ufw_monthly.sh") | crontab -
echo "[+] Done"
