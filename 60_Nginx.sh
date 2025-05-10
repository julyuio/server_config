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

#______________ Installing Passmag_________________

read -p "Installing Password Manager (Passmag) ? (yes/no): " response
if [ "$response" == "yes" ] || [ -z "$response" ]; then
        echo "Proceeding..."
	#some config
	codedir="/code"
	appdir="/code/passmag"

	#creating directories
	mkdir $codedir
	mkdir $appdir
	sleep 10
	#cd /code/passmag
	git clone https://github.com/julyuio/Pass  /code/passmag

	#installing virtual env
	apt install python3.10-venv -y
	echo "Creating Venv..." && sleep 2
	sudo python3 -m venv /code/passmag/venv
	echo "Activating Venv..." && sleep 2
        source /code/passmag/venv/bin/activate
	echo "Installing Requirements..." && sleep2
	pip install -r /code/passmag/requirements.txt
	cp file.gconfig.py /code/passmag/gconfig.py
	echo ""
	echo "In order to activate gunicorn use take a look at gconfig.py and also use the folowing: "
	echo -e "${IGreen} gunicorn -c /code/passmag/gconfig.py Pass.wsgi:application ${Color_Off}"
else
        echo "Skipping PassMag..."
        exit 1
fi
