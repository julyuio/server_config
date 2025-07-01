#!/bin/bash

source conf

MAINDIR=/july/

#_______________Main instalation____________
echo " "
echo -e "${IGreen} Installing Geo Blocking using xtables-addons... ${Color_Off} "
echo " "
sleep 2


echo ""
echo "[+]${IGreen} libxtables-dev installation..${Color_Off} "
echo ""
apt install libxtables-dev -y
echo ""
echo "[+]${IGreen} xtables-addons-common installation.. ${Color_Off}"
echo ""
apt install xtables-addons-common -y
echo ""
echo "[+]${IGreen} libtext-csv-xs-perl installation.. ${Color_Off}"
echo ""
apt install libtext-csv-xs-perl -y
echo ""
echo "[+]${IGreen} pkg-config installation.. ${Color_Off}"
echo ""
apt install pkg-config -y

echo ""
echo "[+] Download xtables addon, untar and configure. Replace"
wget https://inai.de/files/xtables-addons/xtables-addons-3.28.tar.xz
tar xf xtables-addons-3.28.tar.xz
cd xtables-addons-3.28

echo "[+]Waiting 5 sec for a chance to ^C..."
sleep 5
./configure


echo "[+]Waiting 5 sec before 'make'..."
sleep 5
make

echo "[+]Waiting 5 sec 'make install'..."
sleep 5
make install

echo "[+]Download and build DB-IP definitions..."
echo "[+]Waiting 5 sec before xt_geoip_dl..."
sleep 5
cd geoip
./xt_geoip_dl
mkdir /usr/share/xt_geoip

echo "[+]Waiting 5 sec before xt_geoip_build..."
sleep 5
./xt_geoip_build -D /usr/share/xt_geoip *.csv

echo "[+]Installation completed succesfully"
echo "[+]Please Edit and run 34_geoblock_configure.sh "

