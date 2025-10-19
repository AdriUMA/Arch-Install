## Leave blank for ask custom option during installation

# Timezone (ex. "Europe/Madrid")
timezone=

# WiFi or Ethernet ("y"/"n")
wifi=
wifi_device=
wifi_ssid=
wifi_password=

# Partitions location
format_and_mount_ask="y" # "y" to ask before formatting and mounting partitions, "n" to not ask
formatting_script="btrfs"
# Devices (e.g. "/dev/sda1")
root_device=
boot_device= # e.g. "/dev/sda2"
swap_device= # "none" if you don't want a swap partition
boot_mnt_location= # e.g. "/boot" or "/boot/efi"
boot_subvolume= # if you want a subvolume for /boot (y/n)
home_subvolume= # if you want a subvolume for /home (y/n)
var_subvolume= # if you want a subvolume for /var (y/n)
opt_subvolume= # if you want a subvolume for /opt (y/n)
srv_subvolume= # if you want a subvolume for /srv (y/n)

# CPU vendor ("intel"/"amd"/"none")
cpu_vendor=

# Locale (e.g. "en_US.UTF-8 UTF-8", "es_ES.UTF-8 UTF-8")
locale="
en_US.UTF-8 UTF-8
es_ES.UTF-8 UTF-8
"

# Keyboard layout (e.g. "es", "us")
keyboard_layout="us"

# Hostname, root and user (e.g. "arch")
hostname=
root_pass=
user_name=
user_pass=