#!/bin/bash

##############################
# Apt script to install and configure MySQL 8.0
#Author: Jayaranjith
#Date:
#version: v0.1 
##############################

#Validating  Inputs for the password

# set -x #debug option

set -e # Exit on Error


if [ "$#" -ne 1 ]; then
    echo "Input new mysql password as below for futher proceedings"
    echo "Usage: $0 <PASSWORD>"
    exit
fi

#Check MySQL Already install in this Machine

if command -v mysql > /dev/null 2>&1; then
    echo "MySQL Already install in this system"
    exit
fi

#Updating the packages

sudo apt-get update -y && sudo apt-get upgrade -y > /dev/null 2>$1

#Installing MySQL 8.0
sudo apt-get install mysql-server -y > /dev/null 2>$1

#Configuring MySQL
# Install Expect
sudo apt-get -qq install expect > /dev/null

tee ~/secure_our_mysql.sh > /dev/null << EOF

spawn $(which mysql_secure_installation)
expect "Enter password for user root:"
send "$1\r"

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
sudo service mysql starts


#Enable root user to login mysql with password

sudo tee ~/root/.my.cnf <<EOF
[mysqldump]
user = root
password = $1
[mysql]
user= root
password= $1
EOF

echo "MySQL setup completed. Insecure defaults are gone. Please remove this script manually when you are done with it"