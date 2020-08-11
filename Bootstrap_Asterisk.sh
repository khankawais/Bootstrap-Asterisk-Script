######################################################
# Author : Awais khan                                #
# Build Date : 24 July 2020                          #
# Script to install Asterisk 16 on a Debian distro   #
######################################################

# I have only tested this script on Ubuntu 18.04.4 LTS and Ubuntu 20.04 LTS but it should work on other versions too

set -x

if [ $(id -u) != 0 ];then
    printf " \n[X] You must be root to run the script\n" 
else
    apt update
    export DEBIAN_FRONTEND=noninteractive
    # apt upgrade -y
    apt install -y build-essential git-core subversion wget libjansson-dev sqlite autoconf automake libxml2-dev libncurses5-dev libtool

    cd /tmp
    wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz
    tar -zxvf asterisk-16-current.tar.gz
    cd asterisk-16.*/
    apt install -y libedit-dev uuid-dev libsqlite3-dev
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

    # make install-logrotate
    systemctl enable asterisk
    systemctl start asterisk
    #printf "\n\n#############################################\n## Running Aterisk in Verbose Mode\n#############################################\n\n" && sleep 2
    # asterisk -rvvv

fi
