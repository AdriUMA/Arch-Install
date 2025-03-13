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

# Reset iwctl (avoid errors)
echo "${INFO} Reseting iwctl...${RESET}"
iwctl station "$wifi_device" disconnect #> /dev/null 2>&1
sleep 0.25
iwctl device "$wifi_device" set-property Powered off #> /dev/null 2>&1
sleep 0.25
iwctl device "$wifi_device" set-property Powered on #> /dev/null 2>&1
sleep 0.5
iwctl known-networks "$wifi_ssid" forget #> /dev/null 2>&1
sleep 1

# Connect
echo "${INFO} Connecting to WiFi network...${RESET}"
command "iwctl station $wifi_device connect-hidden $wifi_ssid --passphrase $wifi_password"
sleep 0.5
