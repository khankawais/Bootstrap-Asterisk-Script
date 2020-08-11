######################################################
# Author : Awais khan                                #
# Build Date : 24 July 2020                          #
# Script to install Asterisk 16 on a Debian distro   #
######################################################

# I have only tested this script on Ubuntu 18.04.4 LTS but it should work on other versions too

if [ $# -gt 0 ];then
    if [ $1 == "-t" ];then
    printf "\n  This script has been tested on : \n\n  1 - Ubuntu 18.04.4 LTS \n  2 - Ubuntu 20.04 LTS\n\n"
    else
    printf "\n\n  Usage : ./Bootstrap_Asterisk.sh -t   -->  This will list the Tested versions of linux with this script\n\n          ./Bootstrap_Asterisk.sh      -->  This will run start the installation process for Astrisk\n\n\n"
    fi
else

    if [ $(id -u) != 0 ];then
        printf " \n[X] You must be root to run the script\n" 
    else
        apt update
        export DEBIAN_FRONTEND=noninteractive
        apt upgrade -y
        apt-get install build-essential -y
        apt-get install git-core subversion wget libjansson-dev sqlite autoconf automake libxml2-dev libncurses5-dev libtool -y

        cd /usr/src/
        wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz
        tar -zxvf asterisk-16-current.tar.gz
        cd asterisk-16.*/
        apt install libedit-dev uuid-dev libsqlite3-dev -y
        #contrib/scripts/install_prereq install
        ./configure
        make
        make install
        make samples
        make config
        ldconfig

        groupadd asterisk
        adduser --system --group --home /var/lib/asterisk --no-create-home --gecos "Asterisk PBX" asterisk
        usermod -a -G dialout,audio asterisk

        printf "\n\n#############################################\n## Editing Configuration Files\n#############################################\n\n" && sleep 2
        sed -i 's/#AST_USER=/AST_USER=/g' /etc/default/asterisk
        sed -i 's/#AST_GROUP=/AST_GROUP=/g' /etc/default/asterisk
        sed -i 's/;runuser =/runuser =/g' /etc/asterisk/asterisk.conf
        sed -i 's/;rungroup =/rungroup =/g' /etc/asterisk/asterisk.conf
        printf "\n\n#############################################\n## Granting Permissions to the asterisk user\n#############################################\n\n" && sleep 2
        chown -R asterisk: /var/lib/asterisk /var/log/asterisk /var/run/asterisk /var/spool/asterisk /usr/lib/asterisk /etc/asterisk
        chmod -R 750 /var/lib/asterisk /var/log/asterisk /var/run/asterisk /var/spool/asterisk /usr/lib/asterisk /etc/asterisk

        make install-logrotate
        systemctl enable asterisk
        systemctl start asterisk
        #printf "\n\n#############################################\n## Running Aterisk in Verbose Mode\n#############################################\n\n" && sleep 2
        # asterisk -rvvv

    fi

fi
