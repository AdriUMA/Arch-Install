#!/bin/bash

# Ask the user for SSID and password
echo "$(tput setaf 6)   **Easy WiFi**$(tput sgr0)"
read -p "Enter the WiFi network SSID: " wifi_ssid
read -s -p "Enter the WiFi network password: " wifi_password
echo ""

# Attempt to connect up to 3 times
attempts=0
max_attempts=3
success=false

while [[ $attempts -lt $max_attempts ]]; do
    echo "$(tput setaf 4)[INFO]$(tput sgr0) Attempting to connect to $wifi_ssid (Attempt $((attempts+1)) of $max_attempts)..."
    nmcli dev wifi connect "$wifi_ssid" password "$wifi_password" hidden yes
    
    # Check if the connection was successful
    if nmcli -t -f ACTIVE,SSID dev wifi | grep -q "^yes:$wifi_ssid$"; then
        success=true
        break
    fi
    
    ((attempts++))
    sleep 2

done

if $success; then
    echo "$(tput setaf 2)[SUCCESS]$(tput sgr0) Successfully connected to $wifi_ssid."
else
    echo "$(tput setaf 1)[ERROR]$(tput sgr0) Could not connect to $wifi_ssid after $max_attempts attempts."
fi
