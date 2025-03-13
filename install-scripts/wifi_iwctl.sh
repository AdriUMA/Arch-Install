# Unblocking WiFi
echo
command rfkill unblock all

echo
iwctl device list
echo

custom_read " Please enter the name of your WiFi device${RESET}" wifi_device
custom_read " Please enter the name (SSID) of your WiFi network${RESET}" wifi_ssid
custom_read " Please enter the password for your WiFi network${RESET}" wifi_password

echo
echo "${INFO} Connecting to WiFi network...${RESET}"
echo

# Reset iwctl (avoid errors)
iwctl station disconnect 2>&1 /dev/null
iwctl device "\"$wifi_device\"" set-property Powered on 2>&1 /dev/null
iwctl station disconnect 2>&1 /dev/null
iwctl known-networks "\"$wifi_ssid\"" forget

# Connect
command "iwctl station $wifi_device connect-hidden \"$wifi_ssid\" --passphrase \"$wifi_password\""
