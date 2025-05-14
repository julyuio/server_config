#!/bin/bash

source conf

tempdir="/july/test2"

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

#_______________ Install & Configure UFW _______________
echo " "
echo -e "${IGreen} Configuring crontab ufw  ... ${Color_Off} "
sleep 2
echo " "

#________________ Create dir and copy files____________

echo "Creating dirs and copying files..."
if [ ! -d "$tempdir" ]; then
    mkdir -p $tempdir
fi

cp file.crontab_ufw.sh  $tempdir/crontab_ufw.sh
cp file.crontab_ufw_6hours.sh $tempdir/crontab_ufw_daily.sh
touch $tempdir/allow_list.txt
touch $tempdir/ block_list.txt
cp conf $tepdir/conf
cp kompress_ipv4.py $tempdir/kompress_ipv4.py
chmod 775 $tempdir/crontab_ufw.sh
chmod 775 $tempdir/crontab_ufw_daily.sh

echo -e " Run command :${IRed} sudo crontab -e ${Color_Off} and copy the folowing line at the end of the file: "
echo -e " ${IGreen}45  23  *   *   *    $tempdir/crontab_ufw_daily.sh${Color_Off}"
echo -e " ${IGreen}45  23  1   *   *    $tempdir/crontab_ufw.sh${Color_Off}"
echo " "


