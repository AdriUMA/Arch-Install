echo "${YELLOW}Formatting and Mounting ${MAGENTA}(btrfs)${RESET}"
echo
lsblk
echo

# what devices
custom_read " Please enter the device for your btrfs partition (e.g. /dev/sda1)" root_device
custom_read " Please enter the device for your boot partition (e.g. /dev/sda2)" boot_device
custom_read " Please enter the device for your swap (e.g. /dev/sda3 or none)" swap_device
custom_read " Please enter the EFI mount location (e.g. /boot or /boot/efi)" boot_mnt_location

# what subvolumes
ask_yes_no " Subvolume for your home?" home_subvolume
ask_yes_no " Subvolume for your var?$" var_subvolume
ask_yes_no " Subvolume for your opt?" opt_subvolume
ask_yes_no " Subvolume for your srv?" srv_subvolume

echo

# unmount any previous mounts at /mnt
if mountpoint -q /mnt; then
    echo "${INFO} Unmounting any previous mounts at /mnt..."
    umount -fR /mnt
    echo
fi

confirm_format(){
    local formatting_command="$1"
    local device="$2"
    local location="$3"

    if [ "$format_and_mount_ask" != "n" ] && [ "$format_and_mount_ask" != "N" ]; then
        echo "${INFO} $location: $formatting_command"
        read -p "Press enter to continue"
    fi

    echo "${INFO} Formatting the partition..."
    
    # Unmount the device if it is already mounted
    local mount_point=$(findmnt -n -o TARGET "$device")
    if [ -n "$mount_point" ]; then
        echo "${INFO} Unmounted $device from $mount_point"
        umount -fR "$mount_point"
    fi

    mkdir -p "$location"
    command "$formatting_command"
}

subvolume_create(){
    local subvolume="$1"
    local btrfs_mnt_location="$2"

    echo "${INFO} Creating the subvolume $subvolume..."

    command "btrfs subvolume create $btrfs_mnt_location/$subvolume"
}

subvolume_mount(){
    local subvolume="$1"
    local mnt_location="$2"
    local compress="$3"

    echo "${INFO} Mounting the subvolume $subvolume at $mnt_location..."

    mkdir -p "$mnt_location"
    command "mount -o subvol=$subvolume,compress=$compress,noatime,ssd,space_cache=v2,discard=async $root_device $mnt_location"
}

# Format the root partition
device="$root_device"
formatting_command="mkfs.btrfs -f $device"
location="/mnt"
confirm_format "$formatting_command" "$device" "$location"

# Mount the btrfs partition temporarily to create subvolumes
echo
echo "${INFO} Creating and mounting btrfs subvolumes..."
command "mount $device $location"
subvolume_create "@" "/mnt"
[[ "$home_subvolume" =~ ^[Yy]$ ]] && subvolume_create "@home" "/mnt"
[[ "$var_subvolume" =~ ^[Yy]$ ]] && subvolume_create "@var" "/mnt"
[[ "$opt_subvolume" =~ ^[Yy]$ ]] && subvolume_create "@opt" "/mnt"
[[ "$srv_subvolume" =~ ^[Yy]$ ]] && subvolume_create "@srv" "/mnt"

# Unmount the btrfs partition and mount the subvolumes
echo 
echo "${INFO} Unmounting btrfs subvolumes..."
command "umount -Rf $location"

echo
echo "${INFO} Mounting subvolumes..."
subvolume_mount "@" "$location" "zstd"
[[ "$home_subvolume" =~ ^[Yy]$ ]] && subvolume_mount "@home" "/mnt/home" "zstd"
[[ "$var_subvolume" =~ ^[Yy]$ ]] && subvolume_mount "@var" "/mnt/var" "zstd"
[[ "$opt_subvolume" =~ ^[Yy]$ ]] && subvolume_mount "@opt" "/mnt/opt" "zstd"
[[ "$srv_subvolume" =~ ^[Yy]$ ]] && subvolume_mount "@srv" "/mnt/srv" "zstd"

# Format and mount de boot partition
echo
echo "${INFO} Formatting and mounting the boot partition..."
device="$boot_device"
formatting_command="mkfs.fat -F32 $device"
location="/mnt$boot_mnt_location"
confirm_format "$formatting_command" "$device" "$location"
mkdir -p "$location"
command "mount $device $location"

# Format the swap partition
echo
echo "${INFO} Setting up swap partition..."
if [[ "$swap_device" != "none" ]]; then
    if [ "$format_and_mount_ask" != "n" ] && [ "$format_and_mount_ask" != "N" ]; then
        echo "${INFO} mkswap and swapon $swap_device"
        read -p "Press enter to continue"
    fi

    echo "${INFO} Making swap..."
    command "mkswap -f $swap_device"
    command swapon "$swap_device"
fi

echo "$boot_mnt_location" > /mnt/.efi_mount_location

echo
echo "${INFO} Formatting and mounting completed!${RESET}"