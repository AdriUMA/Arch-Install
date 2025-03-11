source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

echo
echo "${ORANGE}Formatting and Mounting${RESET}"
echo "${WARNING}ATTENTION: At this point, you should have the partitions and swap space ready.${RESET}"
echo
lsblk
echo "$root_device"

# what device for /
custom_read " Please enter the device for your root (e.g. /dev/sda1)${RESET}" root_device
# what device for /boot
custom_read " Please enter the device for your boot (e.g. /dev/sda2)${RESET}" boot_device
# what device for /home
custom_read " Please enter the device for your home (e.g. /dev/sda3 or none)${RESET}" home_device
# what device for swap
custom_read " Please enter the device for your swap (e.g. /dev/sda4 or none)${RESET}" swap_device

get_format(){
    if [[ "$1" == "y" ]]; then
        echo "ext4"
    else
        echo "btrfs -f"
    fi
}

# HDD or solid state drive
ask_yes_no " Is your root partition on a HDD?" root_hdd
ask_yes_no " Is your home partition on a HDD?" home_hdd

echo 
echo "${INFO} mkfs.$(get_format $root_hdd) $root_device"
read -p "Press enter to continue" yea



# Format the root partition
echo "${INFO} Formatting and mounting the root partition..."
command mkfs.$(get_format "$root_hdd") "$root_device"
command mount "$root_device" /mnt

# Format the boot partition
echo "${INFO} Formatting and mounting the boot partition..."
command mkfs.fat -F 32 "$boot_device"
command mkdir /mnt/boot
command mount "$boot_device" /mnt/boot

# Format the home partition
if [[ "$home_device" != "none" ]]; then
    echo "${INFO} Formatting and mounting the home partition..."
    command mkfs.$(get_format "$home_hdd") -f "$home_device"
    command mkdir /mnt/home
    command mount "$home_device" /mnt/home
fi

# Format the swap partition
if [[ "$swap_device" != "none" ]]; then
    echo "${INFO} Formatting the swap partition..."
    command mkswap -f "$swap_device"
    command swapon "$swap_device"
fi