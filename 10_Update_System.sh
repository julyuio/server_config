#!/bin/bash

source conf

#__________ Updating System ________________
echo " "
echo -e "${IGreen} Updating system... ${Color_Off} "
sleep 1
echo " "

apt update
apt upgrade -y
