# Unblocking WiFi
command rfkill unblock all

echo
iwctl device list
echo

custom_read " Please enter the name of your WiFi device${RESET}" wifi_device
custom_read " Please enter the name of your WiFi network${RESET}" wifi_ssid
custom_read " Please enter the password for your WiFi network${RESET}" wifi_password

echo
echo "${INFO} Connecting to WiFi network...${RESET}"
echo

iwctl device "\"$wifi_device\"" set-property Powered on
iwctl station disconnect
command "iwctl station $wifi_device connect-hidden \"$wifi_ssid\" --passphrase \"$wifi_password\""
