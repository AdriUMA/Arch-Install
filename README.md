# Arch Linux

## 🤖 Operating System Installation

> [!NOTE]
> Do you want to do the installation on your own? Follow the [official guide](https://wiki.archlinux.org/title/Installation_guide) or [my guide](https://github.com/AdriUMA/Arch-Install/blob/main/README.guide.md).

### ⚠️ Cautions ⚠️

- Only UEFI support (keep reading if you dont know what system is yours).
- Install Windows before Arch for dual boot. Dual boot installation will fail if you have Windows 11 with BitLocker enabled.
- If for any reason SecureBoot needs to be enabled after installing Arch, I recommend deleting all BIOS keys before starting.

### 💿 Preparation

[Download ISO](https://archlinux.org/download/) of Arch Linux and [flash](https://www.balena.io/etcher) an external drive.
Connect the device via Ethernet and boot the live system from the bootable drive.

### ⌨️ Installation

(Optional) Configure the keyboard layout.

```sh
loadkeys es
```

### 🦿 Partitions and Formats

> [!NOTE]
> This is the only manual step.
> For any doubt, see [official guide](https://wiki.archlinux.org/title/Installation_guide).

We will check if the hardware's boot mode is EFI or BIOS for the installation of the operating system.

```sh
ls /sys/firmware/efi/efivars
```

If there is no error running this command, it means it's an EFI boot. Otherwise do not use my script, it is likely an older machine with BIOS boot [manual install](https://github.com/AdriUMA/Arch-Install/blob/main/README.guide.md#-partitions-and-formats).

Check the available drives and the installation target.

```sh
lsblk
```

Run the program to create partitions

> If the option to select a label appears: `gpt` for EFI.

```sh
cfdisk /dev/sdX
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

## Misc

👀 Looking for [auto-install preconfigured environment](https://github.com/AdriUMA/Hyprland-Install)

🔴 Something went wrong? [Guide troubleshooting](https://github.com/AdriUMA/Arch-Install/blob/main/README.guide.md#troubleshooting)
