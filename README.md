# Dotfiles

**Dotfiles** is a collection of configuration files aimed at setting up a personalized and efficient Linux environment. This repository includes configurations for various tools and applications, enhancing productivity and aesthetics.


## Review of Arch (btw)

![1](review/0.webp)
![10](review/1.webp)

| ![2](review/2.webp) | ![3](review/3.webp) |
|---|---|
| ![4](review/4.webp) | ![5](review/5.webp) |
| ![6](review/6.webp) | ![7](review/7.webp) |


## 1. Install ArchLinux With Minimal Configuration

- ### Make a Bootable USB

1. First Download ArchLinux ISO from official site : [Download Link](https://archlinux.org/download/)
2. Second Download for Your Operating System [Ventoy](https://github.com/ventoy/Ventoy/releases)
3. Extract the Ventoy Folder and Write it on your USB.
4. Copy ArchLinux ISO into USB.
   if you Don't Know how to use ventoy read this [article](https://itsfoss.com/use-ventoy/)

- ### Boot From USB

1. Restart Your Computer and Press the Boot Menu key according to your Computer.
2. In Boot Menu Select Your USB
3. It will open ventoy and show you all ISO file available in USB
4. Select the ArchLinux ISO and Open in Normal Mode.

- ### Connect to Internet

1. For wired internet you don't need to do anyting
2. For wireless Command Given Below

```bash
$ iwctl

[iwd]#
```

From the [iwd]# prompt you will need figure out your device name. Then, assuming you know the SSID (service set identifier) of your wireless network, go ahead and connect like so:

```bash
[iwd]# device list

# You should see something like this:
#
#                            Devices
# -------------------------------------------------------------
#   Name          Address          Powered    Adapter    Mode
# -------------------------------------------------------------
#   wlan0         ...              on         ...        ...

[iwd]# station YOURDEVICE connect YOURSSID
```

For a secured wireless network, you will be prompted for the WiFi password. Once you enter the correct password, you’ll be off to the races!

- ### Making Partition Ready for Archinstall
  for that first we will use the `cfdisk` to make partitions and then `mfks` for formatting that

```bash
$ lsblk
```

if will show your all partitions and there information

![cfdisk-img](review/cfdisk.webp)

```bash
$ cfdisk
```

it show you all of your information about your drives

![lsblk-img](review/lsblk.webp)

You have to make 3 partitions

1. EFI boot Partition - Type Must be EFI System
2. Swap Partition - Type Must be Swap Partition
3. Root Partition - Type Must be Linux File System

after Make Partitions write and exit the cfdisk and Run these commands and just change paths

```bash
$ mkfs.ext4 /path/to/root/partition
$ mfks.vfat -F 32 /path/to/efi/partition
$ mkswap /path/to/swap/partition
```

we will use the pre-mounted disk configuration for that run

```bash
$ mkdir /mnt/archinstall
$ mount /path/to/root/partition /mnt/archinstall
$ mkdir /mnt/archinstall/boot
$ mount /path/to/efi/partition/ /mnt/archinstall/boot
$ swapon /path/to/swap/partition
```

now we are done with partitioning the partitions

- ### Update System and Run ArchInstall

```bash
$ pacman -Sy archinstall archlinux-keyring

$ archinstall
```

- ### Actual Installation Start Here

After running the `archinstall` command it will show you something like this.

![archinstall](review/archinstall.webp)

1. **Locales :** In locales select your _keyboard layout_, _locale language_, and _endcoding_
2. **Mirrors :** In Mirrors select best mirror region according to your location
3. **Disk Configuration :** ->Partitioning->Pre-mounted Configuration-> Enter `/mnt/archinstall`
4. **Swap :** Enable it if you made the swap partition
5. **Boot Loader :** Select which boot loader do you need like `grub`, `system-d-boot`
6. **Unified kernel images :** Enable if you want
7. **Hostname :** Select your hostname what you want
8. **Root Password :** Enter Your Root Password
9. **User account :** make a account for normal user
10. **Profile :** Select->Type->Minimal
11. **Audio :** Select->Pipewire
12. **Kernels :** Select one or many according your need. if don't know don't touch it
13. **Network configuration :** Select->Use NetworkManager
14. **Additional packages :** git vim
15. **Optional repositories :** Enable additional repos if you want like `multilib`
16. **Timezone :** Select timezone according to your location
17. **Automatic time sync (NTP) :** Leave Enabled

after that just press the `install` and wait for installation to be finished

![installation-completed-img](review/completed.webp)

Congratulations🎉!! You have successfully installed the ArchLinux and now you can say that _I use Arch btw_

## 2. Installing JaKooLit Arch-Hyprland Script.

reboot your system and login with username and password and connect with internet and clone the repo and preform these operations.

```bash
git clone --depth=1 https://github.com/JaKooLit/Arch-Hyprland.git ~/Arch-Hyprland
cd ~/Arch-Hyprland
chmod +x install.sh
./install.sh
```

select the option according the option given in image I have explained each one of them and those without comment means go with that are in image.

![3](review/arch-hyprland.webp)

After selecting all the options, I will start installing Hyprland and additional components. During the installation, you may be prompted to enter the password 2-3 times, so stay attentive. Once the installation is successful, it will show a prompt to press 'Y' to reboot the system.

![installation](review/installation.webp)

You have successfully installed Archlinux+Hyprland.

## 3. My Dotfiles Configuration

To set up your environment using these dotfiles, follow these steps:

1. **Clone the Repository**:

```bash
git clone https://github.com/ahmad9059/dotfiles.git
cd dotfiles
```

2. **Backup Existing Dotfiles**: Before copying new configurations, it's wise to back up your current dotfiles:

```bash
mkdir -p ~/dotfiles_backup
cp ~/.config ~/dotfiles_backup -r
cp ~/.tmux.conf ~/dotfiles_backup
cp ~/.zshrc ~/dotfiles_backup
```

3. **Copy New Configurations**:
Remember you must in `dotfiles` folder to run following commands

```bash
cp -r .config ~/
cp .zshrc ~/
cp -r .themes ~/.themes
cd .icons
cp .icons.zip ~/
cd ~/
unzip .icons.zip
rm .icons.zip
```

After the installation, you can start using the configured applications. Open your `GTK settings` and set the widget theme to `Andromeda-dark`, the icon theme to `Dracula`, and the mouse cursor to `Future-black Cursors`.
#### Packages `pacman`:
Install of these Packages using `pacman`

```bash
sudo pacman -S foot alacritty lsd bat tmux neovim tldr obs-studio vlc yazi luacheck luarocks hyprpicker firefox obsidian github-cli discord spotify-launcher noto-fonts-emoji  ttf-noto-nerd noto-fonts
```

#### Packages `yay`(Optional):

Install of these Packages Using `yay`. Remember they are according to my preference like I have install vscode, telegram etc.

```bash
yay -S thorium-browser-bin visual-studio-code-bin 64gram-desktop-bin apple-fonts fum foliate whatsapp-for-linux  ttf-sil-scheherazade ttf-kacst ttf-urdufont azuredatastudio-bin stacer-bin localsend-bin wps-office-bin
```


Congratulations! You have successfully completed the installation.
