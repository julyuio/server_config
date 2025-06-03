#!/bin/bash
source conf

welcome_file="/etc/update-motd.d/90-welcome"
logout_file="/etc/bash.bash_logout"
clear_file="/etc/update-motd.d/00-aa"

#__________ Updating System ________________
echo " "
echo -e "${IGreen} Modifying annoying MOTD... ${Color_Off} "
sleep 1
echo " "

chmod -x /etc/update-motd.d/91-release-upgrade
chmod -x /etc/update-motd.d/10-help-text
chmod -x /etc/update-motd.d/50-motd-news

touch $clear_file
chmod +x $clear_file
touch $welcome_file
chmod +x $welcome_file


echo "#!/bin/sh" >$clear_file
echo "clear" >>$clear_file


echo "#!/bin/sh" >$welcome_file
echo "echo" >>$welcome_file
echo "echo" >>$welcome_file
echo "echo '     \033[32mWelcome\033[0m !! ... you magnificent bastard. \033[32mBe good Today\033[0m !!'" >> $welcome_file
echo "echo" >>$welcome_file
echo "echo" >>$welcome_file

echo "clear">$logout_file
echo "echo" >>$logout_file
echo "echo -e 'Have a nice day !! \033[32mBye Bye\033[0m !!'" >>$logout_file
echo "echo" >>$logout_file
