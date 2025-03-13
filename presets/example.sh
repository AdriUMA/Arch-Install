## Leave blank for ask custom option during installation
## WARNING: This is an example DO NOT USE!

# Timezone (ex. "Europe/Madrid")
timezone="Europe/Madrid"

# WiFi or Ethernet ("y"/"n")
wifi="y"
wifi_device="wlan0"
wifi_ssid="MyWifi-AG5S"
wifi_password="MyWifiPassword"

# Partitions location (I DO NOT RECOMMEND USING THIS PRESET) 
format_and_mount_ask="n"
# Devices (e.g. "/dev/sda1")
root_device="/dev/sda2"
boot_device="/dev/sda1"
home_device="/dev/sda3" # "none" if you don't want a separate home partition
swap_device="/dev/sda4" # "none" if you don't want a swap partition
# HDD or solid state drive ("y"/"n")
root_hdd="n"
home_hdd="n"

# CPU vendor ("intel"/"amd"/"none")
cpu_vendor="intel"

# Locale (e.g. "en_US.UTF-8 UTF-8", "es_ES.UTF-8 UTF-8")
locale="
en_US.UTF-8 UTF-8
es_ES.UTF-8 UTF-8
"

# Keyboard layout (e.g. "es", "us")
keyboard_layout="us"

# Hostname, root and user (e.g. "arch")
hostname="archtm"
root_pass=
user_name="adri"
user_pass=
