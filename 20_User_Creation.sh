#!/bin/bash

source conf

#__________ Various Checks___________________

#Checking is username is provided
if [ -z "$1" ] && [-z "${USERNAME}"]; then
    echo -e "${IRed}No username detected,${Color_Off} please provide one : '$0 <username>' "
    exit 1
else
    echo -e "Username provided: ${IGreen}$1 ${USERNAME} ${Color_Off}"
fi
#argument takes priority over variable set
if [ -n "$1" ];then
    USERNAME=$1
fi
#__________ Create user and directories  ___________________

echo " "
echo -e "${IGreen} Creating User... ${Color_Off} "
sleep 2
echo " "

if id "$USERNAME" &>/dev/null; then
        echo -e "${IRed} User $USERNAME already exists.${Color_Off}"
        sleep 1
else
        adduser $USERNAME
        usermod -aG sudo $USERNAME
fi

#
#wgDIR="/home/$USERNAME/wg"
#if [ -d "$wgDIR" ]; then
#  echo " wg Directory exists. Doing nothing..."
#else
#  mkdir $wgDIR
#fi
