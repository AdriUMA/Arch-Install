source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Unblocking WiFi
command rfkill unblock all

echo
echo iwctl device list
echo

custom_read "${CAT} ${SKY_BLUE}Please enter the name of your WiFi device: ${RESET}" wifi_device
custom_read "${CAT} ${SKY_BLUE}Please enter the name of your WiFi network: ${RESET}" wifi_ssid
custom_read "${CAT} ${SKY_BLUE}Please enter the password for your WiFi network: ${RESET}" wifi_password

echo
echo "${INFO} Connecting to WiFi network...${RESET}"
echo

command iwctl station "$wifi_device" connect-hidden "$wifi_ssid" --passphrase "$wifi_password"