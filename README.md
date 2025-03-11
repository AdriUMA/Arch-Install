# Arch Linux

## 🤖 Operating System Installation

> [!IMPORTANT]
> I recommend using the [official installation guide](https://wiki.archlinux.org/title/Installation_guide). This is a simplified summary adapted to my needs. It may not take into account hardware different from the one I have on my devices.

> [!WARNING]
> If for any reason SecureBoot needs to be enabled after installing Arch, I recommend deleting all BIOS keys before starting.

> [!CAUTION]
> Install Windows before Arch for dual boot.
> Dual boot installation will fail if you have Windows 11 with BitLocker enabled.

### Preparation

[Download ISO](https://archlinux.org/download/) of Arch Linux and [flash](https://www.balena.io/etcher) an external drive.
Connect the device via Ethernet and boot the live system from the bootable drive.

### Installation

(Optional) Configure the keyboard layout.

```sh
loadkeys es
```

### 🦿 Partitions and Formats

We will check if the hardware's boot mode is EFI or BIOS for the installation of the operating system.

```sh
ls /sys/firmware/efi/efivars
```

If there is no error running this command, it means it's an EFI boot. Otherwise, it is likely an older machine with BIOS boot.

Check the available drives and the installation target.

```sh
lsblk
```

Run the program to create partitions

> If the option to select a label appears: `gpt` for EFI.

```sh
cfdisk sdX
```

Create partitions for the operating system or root `/`, for users `/home`, and for swap memory `swap`.

Partition for **EFI**

> [!IMPORTANT] If you have another Linux installed, you have multiple options if you want to keep it. However, for the sake of simplicity, this guide does not consider that case.

| Path     | Type             | Suggested Size |
| -------- | ---------------- | -------------- |
| `/`      | Linux filesystem | 50GB           |
| `/boot`  | EFI System       | 1GB            |
| `/home`  | Linux filesystem | 50GB           |
| `[SWAP]` | Linux swap       | 8GB            |

Run installer

```sh
git clone https://github.com/AdriUMA/Arch-Install.git
cd Arch-Install
chmod +x install.sh
./install.sh
```

## ⚠️ If everything went well but GRUB does not appear in the BIOS boot menu ⚠️

### 1️⃣ First: **Clean `/boot` and mount**

🅰️ **IF YOU HAVE `/boot` ON A SEPARATE PARTITION**  

For example, if you have:

- `/` on /dev/sda1  
- `/home` on /dev/sda2  
- swap on /dev/sda3  
- `/boot` on /dev/sda4  

Mount the partitions except for `boot`:

```sh
mount /dev/sda1 /mnt
mount /dev/sda2 /mnt/home
swapon /dev/sda3
```

Format `/boot`, mount it, and regenerate fstab:

```sh
mkfs.fat -F 32 /dev/sda4
mount /dev/sda4 /mnt/boot
genfstab -U > /mnt/etc/fstab
```

🅱️ **IF YOU DON'T HAVE `/boot` ON A SEPARATE PARTITION**  

For example, if you have:

- `/` on /dev/sda1  
- swap on /dev/sda3  

```sh
mount /dev/sda1 /mnt
swapon /dev/sda3
```

Then, remove the contents of `/boot`:

```sh
rm -rf /mnt/boot/*
```

### 2️⃣ Second: Regenerate files in `/boot` and install GRUB  

Enter the system and reinstall `linux` to regenerate files in `/boot`:

```sh
arch-root /mnt
pacman -Syy
pacman -S linux
mkinitcpio -P
```

Install GRUB with an additional flag:

> If you want to detect other operating systems: install `os-prober` and uncomment the line in `/etc/default/grub` at the end of the document so that it looks like this:  
> `GRUB_DISABLE_OS_PROBER=false`

```sh
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable
grub-mkconfig -o /boot/grub/grub.cfg
```

### 3️⃣ Third: Restart  

```sh
umount -R /mnt
shutdown now
```
