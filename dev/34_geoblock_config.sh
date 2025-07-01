#!/bin/bash

source conf

echo "[+]Start Blocking.."
echo "By default if the security is high you should block everything and then allow speciific countries. This script is for low security Allowing everything and only blocking specific countries..." 
echo "If you want to block everything use:    iptables --policy INPUT DROP"

echo "[+]Blocking..."
sleep 1
# Block Russia
iptables -I INPUT -m geoip --src-cc RU -j DROP

# Block all countries in Africa
iptables -I INPUT -m geoip --src-cc AO,BF,BI,BJ,BW,CD,CF,CG,CI,CM,DJ,DZ,EG,ER,ET,GA,GH,GM,GN,GQ,KE,KM,LR,LS,LY,MA,MG,ML,MR,MU,MW,MZ,NA,NE,NG,RE,RW,SC,SD,SH,SL,SN,SO,SS,ST,SZ,TD,TG,TN,TZ,UG,YT,ZA,ZM,ZW -j DROP

# Block North America (US, Canada, Mexico)
#iptables -I INPUT -m geoip --src-cc US,CA,MX -j DROP

#Europe
#Germany
#iptables -I INPUT -m geoip --src-cc DE -j DROP
#Poland
#iptables -I INPUT -m geoip --src-cc PL -j DROP
#Nederlands
#iptables -I INPUT -m geoip --src-cc NL -j DROP

echo "[+]Done!"
