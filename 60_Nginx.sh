#!/bin/bash
source conf

# Check if Nginx is installed
if command -v nginx &> /dev/null
then
    echo "Nginx is installed."
    nginx -v  # Display the version
else
    	echo "Nginx is NOT installed."
	apt install nginx -y
	system nginx start
fi

#______________ Installing gunicorn_________________

read -p "Installing gunicorn ? (yes/no): " response
if [ "$response" == "yes" ] || [ -z "$response" ]; then
        echo "Proceeding..."
	apt install gunicorn -y
else
        echo "Operation canceled."
fi
