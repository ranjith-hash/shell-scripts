#!/bin/bash

#################################################################################################
# This script will check RAM usage and reboot the server if exceeds the threshold
# Author: Jayaranjith 
# Version: v0.0.1
# Usage: ./FILE_NAME 
#################################################################################################


#public_ip=$(curl -s ipinfo.io/ip)
# Get memory usage details
memory_info=$(free | grep Mem)
memory_usage_threshold=85

# Extract total and used memory values
total_memory=$(echo $memory_info | awk '{print $2}')
used_memory=$(echo $memory_info | awk '{print $3}')

# Calculate the percentage of used memory
ram_usage_percentage=$(awk "BEGIN {printf \"%.2f\", ($used_memory/$total_memory)*100}")
round_up_percentage=$(echo "$ram_usage_percentage" | awk '{printf "%d", $1}')

# Print the RAM usage percentage
echo "RAM usage is $ram_usage_percentage%"

if [ $round_up_percentage -gt $memory_usage_threshold ] ; then
    echo "Rebooting System due to $memory_usage_threshold % usage of ram"
    sudo reboot
fi


