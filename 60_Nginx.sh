#!/bin/bash
source conf

echo " "
echo -e "${IGreen} Installing Nginx... ${Color_Off} "
sleep 2
echo " "

# Check if Nginx is installed
if command -v nginx &> /dev/null
then
    echo "Nginx is installed."
    nginx -v  # Display the version
else
    	echo "Nginx is NOT installed."
	apt install nginx -y
	systemctl nginx start
fi

