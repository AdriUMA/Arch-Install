#!/bin/bash

clear

# Check if --preset argument is provided
if [[ "$1" == "--preset" ]]; then

    if [ -z "$2" -o ! -f "$2" ]; then
        echo "$ERROR Preset $2 not found, aborting."
        exit 1
    fi
    
    use_preset="$(realpath $2)"
fi

source "install-scripts/Global_functions.sh"

printf "\n%.0s" {1..2}  
echo -e "\e[35m\n
        ╔═╗┬─┐┌─┐┬ ┬
        ╠═╣├┬┘│  ├─┤
        ╩ ╩┴└─└─┘┴ ┴
\e[0m"
printf "\n%.0s" {1..1} 

echo "${SKY_BLUE}Welcome to Adri's Arch Install Script!${RESET}"
echo
echo "${YELLOW}NOTE: You will be required to answer some questions during the installation! ${RESET}"
echo
echo "${WARNING}ATTENTION: Before proceeding, make sure you have disks and partitions ready!${RESET}"
echo
read -p "${CAT} ${SKY_BLUE}Would you like to proceed? (y/n): ${RESET}" proceed

if [ "$proceed" != "y" ]; then
    printf "\n%.0s" {1..2}
    echo "${INFO} Installation aborted. ${SKY_BLUE}No changes in your system.${RESET} ${YELLOW}Goodbye!${RESET}"
    printf "\n%.0s" {1..2}
    exit 1
fi

# Only for UEFI mode
echo
echo "${INFO} Detecting EFI mode..."
command ls /sys/firmware/efi/efivars
echo "${OK} EFI mode detected.${RESET}"
echo

# Timezone
custom_read " Please enter your timezone (ex. Europe/Madrid)${RESET}" timezone
echo "${INFO} Setting timezone...${RESET}"
command "timedatectl set-timezone $timezone"
command timedatectl set-ntp true
echo

# WiFi or Ethernet
ask_yes_no " Do you want to use WiFi?" wifi

if [ "$wifi" = "y" ] || [ "$wifi" = "Y" ]; then
    execute_script "wifi_iwctl.sh"
fi

# Check internet connection
execute_script "check_internet.sh"

echo

# Format and mount partitions
ask_custom_option " Please enter the formatting and mounting script you want to use" "ext4 btrfs" formatting_script
execute_script "formatting_mounting_$formatting_script.sh"

echo

# Check /mnt
execute_script "check_mount.sh"

echo

# Install the base system
ask_custom_option " Enter your CPU vendor" "intel amd none" cpu_vendor

echo
echo "${INFO} Installing the base system...${RESET}"
echo "${INFO}This may take a while, please be patient...${RESET}"

cpu_vendor_ucode=""
if [ "$cpu_vendor" = "intel" ]; then
    cpu_vendor_ucode="intel-ucode"
elif [ "$cpu_vendor" = "amd" ]; then
    cpu_vendor_ucode="amd-ucode"
fi
command_verbose "pacstrap /mnt base linux linux-firmware git sudo nano networkmanager $cpu_vendor_ucode" 

# Generate fstab
echo
echo ${INFO} Generating fstab...${RESET}

command "genfstab -U /mnt >> /mnt/etc/fstab"

# Copy the arch-chroot-scripts directory to the new system
echo
echo ${INFO} Copying arch-chroot-scripts directory to the new system...${RESET}
command "cp -r assets/arch-chroot-scripts /mnt/root"

if [ -n "$use_preset" ]; then
    command "cp $use_preset /mnt/root/arch-chroot-scripts/preset.sh"
fi

command "chmod +x /mnt/root/arch-chroot-scripts/*"

# Enter the new system
echo
echo ${INFO} Entering the new system...${RESET}
command_verbose "arch-chroot /mnt /root/arch-chroot-scripts/setup.sh"

# Remove the arch-chroot-scripts directory from the new system
echo
echo ${INFO} Removing arch-chroot-scripts directory from the new system...${RESET}
command "rm -rf /mnt/root/arch-chroot-scripts"

echo
echo ${GREEN} Install completed!${RESET}
echo

# Finish
ask_yes_no " Do you want to reboot now?" reboot

if [ "$reboot" = "y" ] || [ "$reboot" = "Y" ]; then
    echo
    echo ${INFO} Rebooting...${RESET}
    echo
    umount -R /mnt
    reboot
else
    echo
    echo ${INFO} You can reboot later by running the command: ${GREEN}reboot${RESET}
    echo
fi

