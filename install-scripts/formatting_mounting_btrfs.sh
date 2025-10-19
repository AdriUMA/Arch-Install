echo "${MAGENTA}Formatting and Mounting${RESET}"
echo "${WARNING}ATTENTION: At this point, you should have the partition and swap space ready.${RESET}"
echo
lsblk
echo

# what devices
custom_read " Please enter the device for your btrfs partition (e.g. /dev/sda1)${RESET}" root_device
custom_read " Please enter the device for your swap partition (e.g. /dev/sda2 or none)${RESET}" swap_device

# what subvolumes
custom_read " Subvolume for your boot (y/n)?${RESET}" boot_subvolume
custom_read " Subvolume for your home (y/n)?${RESET}" home_subvolume
custom_read " Subvolume for your var (y/n)?${RESET}" var_subvolume
custom_read " Subvolume for your opt (y/n)?${RESET}" opt_subvolume
custom_read " Subvolume for your srv (y/n)?${RESET}" srv_subvolume
 
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
    command "$formatting_command $device"
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
command "mount $device $location"
subvolume_create "@" "/mnt"
[[ "$boot_subvolume" =~ ^[Yy]$ ]] && subvolume_create "@boot" "/mnt"
[[ "$home_subvolume" =~ ^[Yy]$ ]] && subvolume_create "@home" "/mnt"
[[ "$var_subvolume" =~ ^[Yy]$ ]] && subvolume_create "@var" "/mnt"
[[ "$opt_subvolume" =~ ^[Yy]$ ]] && subvolume_create "@opt" "/mnt"
[[ "$srv_subvolume" =~ ^[Yy]$ ]] && subvolume_create "@srv" "/mnt"

# Unmount the btrfs partition and mount the subvolumes
command "umount -Rf $location"
subvolume_mount "@" "$location"
[[ "$boot_subvolume" =~ ^[Yy]$ ]] && subvolume_mount "@boot" "/mnt/boot" "none"
[[ "$home_subvolume" =~ ^[Yy]$ ]] && subvolume_mount "@home" "/mnt/home" "zstd"
[[ "$var_subvolume" =~ ^[Yy]$ ]] && subvolume_mount "@var" "/mnt/var" "zstd"
[[ "$opt_subvolume" =~ ^[Yy]$ ]] && subvolume_mount "@opt" "/mnt/opt" "zstd"
[[ "$srv_subvolume" =~ ^[Yy]$ ]] && subvolume_mount "@srv" "/mnt/srv" "zstd"

# Format the swap partition
if [[ "$swap_device" != "none" ]]; then
    if [ "$format_and_mount_ask" != "n" ] && [ "$format_and_mount_ask" != "N" ]; then
        echo "${INFO} mkswap and swapon $swap_device"
        read -p "Press enter to continue"
    fi

    echo "${INFO} Making swap..."
    command "mkswap -f $swap_device"
    command swapon "$swap_device"
fi
