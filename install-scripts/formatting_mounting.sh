source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

echo
echo "${MAGENTA}Formatting and Mounting${RESET}"
echo "${WARNING}ATTENTION: At this point, you should have the partitions and swap space ready.${RESET}"
echo
lsblk
echo

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

confirm_format_and_mount(){
    if [ "$format_and_mount_ask" == "y" ] || [ "$format_and_mount_ask" == "Y" ]; then
        echo "${INFO} $1 on $2"
        read -p "Press enter to continue"
    fi
}

# Format the root partition
device="$root_device"
next_command="mkfs.$(get_format $root_hdd) $device"
location="/mnt"
confirm_format_and_mount "$next_command" "$location"

echo "${INFO} Formatting and mounting the root partition..."
command "$next_command" "$root_device"
command mount "$root_device" "$location"

echo "${INFO} $next_command on /mnt/boot"
read -p "Press enter to continue"

# Format the boot partition
device="$boot_device"
next_command="mkfs.fat -F 32 $device"
location="/mnt/boot"
confirm_format_and_mount "$next_command" "$location"

echo "${INFO} Formatting and mounting the boot partition..."
command mkdir "$location"
command mkfs.fat -F 32 "$device"
command mount "$device" "$location"

# Format the home partition
if [[ "$home_device" != "none" ]]; then
    device="$home_device"
    next_command="mkfs.$(get_format $home_hdd) $device"
    location="/mnt/home"
    confirm_format_and_mount "$next_command" "$location"

    echo "${INFO} Formatting and mounting the home partition..."
    command mkdir "$location"
    command "$next_command"
    command mount "$device" "$location"
fi

# Format the swap partition
if [[ "$swap_device" != "none" ]]; then
    echo "${INFO} mkswap and swapon $swap_device"
    read -p "Press enter to continue"

    echo "${INFO} Formatting the swap partition..."
    command mkswap -f "$swap_device"
    command swapon "$swap_device"
fi