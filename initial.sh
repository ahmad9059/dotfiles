#!/bin/bash

set -e

# ===========================
# Color-coded status labels
# ===========================
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
OK="$(tput setaf 2)[OK]$(tput sgr0)"
NOTE="$(tput setaf 6)[NOTE]$(tput sgr0)"
RESET="$(tput sgr0)"

echo "${NOTE} Adding Chaotic-AUR repository...${RESET}"

# Import Chaotic AUR keys
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

# Install chaotic-keyring and chaotic-mirrorlist
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Append chaotic-aur repo if not already present
if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
  echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
  echo "${OK} Chaotic-AUR repo added to pacman.conf${RESET}"
else
  echo "${NOTE} Chaotic-AUR repo already exists in pacman.conf${RESET}"
fi

# Sync and update system
echo "${NOTE} Updating system with Chaotic-AUR mirrors...${RESET}"
sudo pacman -Syu --noconfirm

# Install wallust and quickshell
echo "${NOTE} Installing wallust and quickshell...${RESET}"
sudo pacman -S --noconfirm wallust quickshell

echo "${OK} Installation complete!${RESET}"
