#!/bin/bash

source conf

DATE=$(date +%Y-%m)
URL="https://download.db-ip.com/free/dbip-city-lite-${DATE}.mmdb.gz"
DEST_DIR="/usr/share/geoip"
DEST_FILE="${DEST_DIR}/dbip-city-${DATE}.mmdb.gz"
DEST_FILE_nogz="${DEST_DIR}/dbip-city-${DATE}.mmdb"
GOACC_REPORT="zcat -f /var/log/nginx/access.log*.gz  /var/log/nginx/access.log* | goaccess - --log-format=COMBINED --geoip-database=$DEST_FILE_nogz -o /var/www/html/georeport.html >> /july/cron.log 2>&1"
GOACC_REPORT_NO404="zcat -f /var/log/nginx/access.log*.gz  cat /var/log/nginx/access.log* | goaccess - --ignore-status=400 --ignore-status=301 --ignore-status=302 --ignore-status=403 --ignore-status=404 --log-format=COMBINED --geoip-database=$DEST_FILE_nogz -o /var/www/html/georeport_no404.html >> /july/cron.log 2>&1"
GOACC_REPORT_REF="zcat -f /var/log/nginx/access.log*.gz /var/log/nginx/access.log* | awk '$11 != \"-\" && $11 != \"\\\"-\\\"\"' | goaccess --ignore-status=400 --ignore-status=404 --ignore-status=408 --log-format=COMBINED --geoip-database=$DEST_FILE_nogz -o /var/www/html/georeport_ref_only.html"

echo " "
echo -e "${IGreen} Installing Go Access and Geo tools ${Color_Off} "
echo " "
sleep 2

#Check if goaccess is installed
if ! command -v goaccess &> /dev/null
then
    echo "Goaccess is not installed. Installing..."
    apt install goaccess -y
fi

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Download the database

if [ -f $DEST_FILE_nogz ]; then
     echo "[+] DB-IP file exists..."
else
     curl -o "$DEST_FILE" "$URL"
     gunzip -f "$DEST_FILE"
     echo "[+] DB-IP City Lite database downloaded and extracted to $DEST_DIR"
fi


echo -e -n "$total_ips${IRed}Adding Goaccess to crontab ${IGreen}  ${Color_Off} ...continue ? (y/n)"
read response
  if [ "$response" = "y" ] || [ -z "$response" ]; then
       if crontab -l 2>/dev/null | grep -q 'goaccess'; then
            echo -e "[+] Script is already in crontab ${IRed} You have to edit using crontab -e and remove extra lines${Color_Off}"
       else
            echo "[+] Adding lines to crontab"
       fi

	(crontab -l 2>/dev/null; echo "26 * * * * $GOACC_REPORT") | crontab -
	(crontab -l 2>/dev/null; echo "27 * * * * $GOACC_REPORT_NO404") | crontab -
        (crontab -l 2>/dev/null; echo "28 * * * * $GOACC_REPORT_REF") | crontab -

  else
            echo "Please add them manually... "
	    echo -e " ${IGreen} 26 * * * * $GOACC_REPORT ${Color_Off}"
	    echo ""
	    echo -e " ${IGreen} 27 * * * * $GOACC_REPORT_NO404 ${Color_Off}"
  fi

echo "[+] Done"
