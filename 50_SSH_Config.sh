#!/bin/bash

source conf

#Checking is username is provided
if [ -z "$1" ] && [ -z "${SSHPort}" ]; then
    echo -e "${IRed}No porn number detected,${Color_Off} please provide one : '$0 <port no>' "
    exit 1
else
    echo -e "Port provided: ${IGreen}$1 ${SSHPort} ${Color_Off}"
fi
#argument takes priority over variable set
if [ -n "$1" ];then
    SSHPort=$1
fi

#__________ Installing new ssh config  ___________________

echo " "
echo -e "${IGreen} Installing new ssh config ... ${Color_Off} "
sleep 2
echo " "

echo "Please generate a RSA key with 4096 either manually or with Terminus. TO generate it manually, open a local console and type :"
echo "     ssh-keygen -t rsa -b 4096 "
echo -e "Open a new terminal window and copy the new pub key to this server under your home ${IGreen}~/.ssh/authorized_keys${Color_Off} either manually or thoguht SCP"
echo "Alternatively open Terminus , go to keys, generate a new one, click the 3 dots ... and export to host"
sleep 5
echo " "
echo -n -e "${IRed} Have you done it ? (y/n)${Color_Off} "
read response
if [ "$response" = "y" ] || [ -z "$response" ]; then
    echo -n -e "${IRed} Going to copy sshconfig and replace the default one. ${IGreen} Are you sure you would like to continue ? (y/n)${Color_Off} "
    read response

        if [ "$response" = "y" ] || [ -z "$response" ]; then
            	#back up sshd file just in case 
		cp /etc/ssh/sshd_config /tmp/sshd_config

		#copy the sshd config file , tested on Ubuntu 22 
		cp file.sshd_config.ubuntu22 /etc/ssh/sshd_config

		#Add Port number to the end of the sshd_config
		echo "Port $SSHPort" >> /etc/ssh/sshd_config
            	echo "Done...Restarting sshd, might loose connection."
            	sleep 2
            	service sshd restart
        else
            echo "Please do it manually... "
        fi
else
    echo "Please do it manually... "
fi


echo -e "Denying port 22, alowing port $SSHPort. ${IRed}Do not forget to add it to the VPS firewall !!${Color_Off}"
counter=0
while [ $counter -lt 5 ]; do
    counter=$((counter + 1))
    echo -n "... $counter"$'\r'
    sleep 1
done

if  which ufw >null;then
  ufw deny 22
  ufw allow $SSHPort
  ufw reload
fi
