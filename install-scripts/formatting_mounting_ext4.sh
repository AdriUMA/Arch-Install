echo "${YELLOW}Formatting and Mounting ${MAGENTA}(ext4)${RESET}"
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

confirm_format_and_mount(){
    local formatting_command="$1"
    local device="$2"
    local location="$3"

    if [ "$format_and_mount_ask" != "n" ] && [ "$format_and_mount_ask" != "N" ]; then
        echo "${INFO} $location: $formatting_command"
        read -p "Press enter to continue"
    fi

    echo "${INFO} Formatting and mounting the partition..."
    
    # Unmount the device if it is already mounted
    local mount_point=$(findmnt -n -o TARGET "$device")
    if [ -n "$mount_point" ]; then
        echo "${INFO} Unmounted $device from $mount_point"
        umount -fR "$mount_point"
    fi

    mkdir -p "$location"
    command "$formatting_command $device"
    command "mount $device $location"
}

# Format the root partition
device="$root_device"
formatting_command="mkfs.ext4 $device"
location="/mnt"
confirm_format_and_mount "$formatting_command" "$device" "$location"

# Format the boot partition
device="$boot_device"
formatting_command="mkfs.fat -F 32 $device"
location="/mnt/boot"
confirm_format_and_mount "$formatting_command" "$device" "$location"

# Format the home partition
if [[ "$home_device" != "none" ]]; then
    device="$home_device"
    formatting_command="mkfs.ext4 $device"
    location="/mnt/home"
    confirm_format_and_mount "$formatting_command" "$device" "$location"
fi

# Format the swap partition
if [[ "$swap_device" != "none" ]]; then
    if [ "$format_and_mount_ask" != "n" ] && [ "$format_and_mount_ask" != "N" ]; then
        echo "${INFO} mkswap and swapon $swap_device"
        read -p "Press enter to continue"
    fi

    echo "${INFO} Making swap..."
    command "mkswap -f $swap_device"
    command "swapon $swap_device"
fi
