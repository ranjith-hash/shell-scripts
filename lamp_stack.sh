#!/bin/bash

#################################################################################################
# This script will install and configure LAMP (Linux, Apache2, PHP, MySQL) Stack on ubuntu distro
# NOTE: THIS SCRIPT WILL GENERATE MYSQL PASSWORD AUTOMATICALLY AND SAVE ON ~/. my.cnf, 
# ROOT user can able to access the MySQL without password
# Author: Jayaranjith 
# Version: v0.0.1
# Usage: ./FILE_NAME <php-version>
#################################################################################################

#GLOBAL VARIABLES



######################################
#Validating input parameters
######################################

set -e

if [ "$#" -ne 1 ]; then
    echo "php version required for further proceedings"
    echo "Usage: $0 <php-version>"
    exit
fi

######################################
# Updating the packages
######################################

sudo apt-get update -y && sudo apt-get upgrade -y > /dev/null 2>&1

#Install Apache2 if not present

if ! command -v apache2 > /dev/null 2>&1 ; then
    sudo apt-get install apache2 libapache2-mod-php -y
fi

######################################
#Install PHP specific version based on input
######################################


#Adding PPA 

sudo add-apt-repository ppa:ondrej/php -y

echo "Installing php$1"

sudo apt-get update -y > /dev/null 2>&1

#Installing required php version and modules
sudo apt install php$1 php$1-cli php$1-{bz2,curl,mbstring,intl,gd,xml,xmlrpc,soap,zip} -y

######################################
#Install and Configure MySQL
######################################


if command -v mysql > /dev/null 2>&1; then
    echo "MySQL Already install in this system"
    exit
else

    sudo apt-get install pwgen -y 
    # Generate a random password of 12 characters
    password=$(pwgen -s -N 1 -cny 12)

    #Installing MySQL 8.0
    sudo apt-get install mysql-server -y > /dev/null 2>&1

    #Configuring MySQL
    # Install Expect
    sudo apt-get -qq install expect > /dev/null 2>&1

    tee ~/secure_our_mysql.sh > /dev/null << EOF

    spawn $(which mysql_secure_installation)
    expect "Enter password for user root:"
    send "$password\r"

    expect "Press y|Y for Yes, any other key for No:"
    send "y\r"

    expect "Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:"
    send "2\r"

    expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
    send "n\r"

    expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
    send "y\r"
EOF

    sudo expect ~/secure_our_mysql.sh


    #Enabling and Starting 
    sudo systemctl enable mysql
    sudo service mysql start


    #Enable root user to login mysql with password

    sudo tee ~/root/.my.cnf <<EOF
    [mysqldump]
    user=root
    password=$password
    [mysql]
    user=root
    password=$password
EOF

    echo "MySQL setup completed. Insecure defaults are gone. Please remove this script manually when you are done with it"
    
fi

