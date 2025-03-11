# If preset.sh is provided, define it (this is for Global_functions.sh):
if [ -f "preset.sh" ]; then
    use_preset="$(realpath preset.sh)"
fi

source "$(dirname $(readlink -f $0))/Global_functions.sh"

# Set the timezone
echo
echo "${INFO} Setting timezone $timezone${RESET}"
command "ln -sf /usr/share/zoneinfo/$timezone /etc/localtime"
command "hwclock --systohc"

# Set the locale
echo
another_locale="Y"
while [ "$another_locale" == "Y" ]; do
    unset another_locale
    
    custom_read " Please enter the locale you want to add (ex. en_US.UTF-8 UTF8, es_ES.UTF-8 UTF8)${RESET}" locale
    echo "$locale" >> /etc/locale.gen
    
    # If we are running using preset, we don't want to ask for more locales
    if [ ! -z "$use_preset" ]; then
        break
    fi

    ask_yes_no " Do you want to add another locale?" another_locale
done

echo
echo "${INFO} Generating locales...${RESET}"
command "locale-gen"

# Keyboard layout
echo
echo "${INFO} Keyboard layout${RESET}"
custom_read -p "${CAT} ${SKY_BLUE}Please enter your keyboard layout (ex. es, us): ${RESET}" keyboard_layout
echo "KEYMAP=$keyboard_layout" > /etc/vconsole.conf

# Hostname
echo
custom_read -p "${CAT} ${SKY_BLUE}Please enter your hostname: ${RESET}" hostname
echo "${INFO} Setting hostname $hostname${RESET}"
echo "$hostname" > /etc/hostname
echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.1.1     $hostname.localhost        $hostname" >> /etc/hosts

echo "${INFO} Enabling NetworkManager...${RESET}"
command "systemctl enable NetworkManager"

# Root password
echo "${INFO} Setting root password...${RESET}"
if [ -z "$root_pass" ]; then
    while true; do
        custom_read -sp "${CAT} ${SKY_BLUE}Enter root password: ${RESET}" root_pass
        echo
        custom_read -sp "${CAT} ${SKY_BLUE}Re-enter root password: ${RESET}" root_pass2
        echo
        [ "$root_pass" = "$root_pass2" ] && break
        echo "${ERROR} Passwords do not match. Please try again."
    done
fi
command "echo root:$root_pass | chpasswd"

# User name and password
echo
custom_read -p "${CAT} ${SKY_BLUE}Please enter your username: ${RESET}" user_name
command "useradd -m $user_name"
echo "${INFO} Setting user password...${RESET}"
if [ -z "$user_pass" ]; then
    while true; do
        custom_read -sp "${CAT} ${SKY_BLUE}Enter user password: ${RESET}" user_pass
        echo
        custom_read -sp "${CAT} ${SKY_BLUE}Re-enter user password: ${RESET}" user_pass2
        echo
        [ "$user_pass" = "$user_pass2" ] && break
        echo "${ERROR} Passwords do not match. Please try again."
    done
fi
command "echo $user_name:$user_pass | chpasswd"

# User groups and sudo
echo "${INFO} Groups and sudo for $user_name...${RESET}"
command "usermod -aG wheel,video,audio,storage $user_name"
command "sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers"

# Configure wifi for next boot
if [ "$wifi" = "y" ] || [ "$wifi" = "Y" ]; then
    echo "${INFO} Configuring wifi for next boot...${RESET}"
    command "nmcli dev wifi connect $wifi_ssid name $wifi_ssid password $wifi_password hidden yes"
fi

# GRUB

echo "${INFO} Downloading GRUB...${RESET}"
command "pacman -S grub efibootmgr os-prober --noconfirm"
sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub

echo "${INFO} Installing GRUB...${RESET}"
command "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB"

echo "${INFO} Generating GRUB configuration...${RESET}"
command "grub-mkconfig -o /boot/grub/grub.cfg"

echo "${INFO} GRUB installed!${RESET}"

# Finish
echo
echo "${INFO} Setup completed!${RESET}"

sleep 1

exit 0
