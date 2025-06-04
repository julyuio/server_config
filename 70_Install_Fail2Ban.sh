#!/bin/bash

source conf


#__________ Installing fail2ban  ___________________

echo " "
echo -e "${IGreen} Installing fail2ban ... ${Color_Off} "
sleep 2
echo " "

apt install fail2ban -y

echo "Copying conf files..."
cp file.jail.local /etc/fail2ban/jail.local
cp file.nginx-4xx.conf /etc/fail2ban/filter.d/nginx-4xx.conf
echo "Restarting fail2ban..."
service fail2ban restart
echo "Done"
