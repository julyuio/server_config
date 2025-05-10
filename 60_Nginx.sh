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
	sleep 2
	#cd /code/passmag
	git clone https://github.com/julyuio/Pass  $appdir

	#installing virtual env
	apt install python3.10-venv -y
	echo "Creating Venv..." && sleep 2
	sudo python3 -m venv $appdir/venv
	echo "Activating Venv..." && sleep 2
        source $appdir/venv/bin/activate
	echo "Installing Requirements..." && sleep2
	pip install -r $appdir/requirements.txt
	cp file.gconfig.py $appdir/gconfig.py
	echo ""
	echo -e "${IRed}Step1:${Color_Off} Activate venv "
	echo -e "${IRed}Step2:${Color_Off} take a look at gconfig.py in the same folder as app"
	echo -e "${IRed}Step3:${Color_Off} run the folowing command:"
	echo -e "${IGreen} gunicorn -c $appdir/gconfig.py Pass.wsgi:application ${Color_Off}"
	echo "Further configuation and creating of the database is needed inside the app."
	echo ""
else
        echo "Skipping PassMag..."
        exit 1
fi
