#!/bin/bash

set -e

# ===========================
# Color-coded status labels
# ===========================
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
WARN="$(tput setaf 3)[WARN]$(tput sgr0)"
OK="$(tput setaf 2)[OK]$(tput sgr0)"
NOTE="$(tput setaf 6)[NOTE]$(tput sgr0)"
ACTION="$(tput setaf 5)[ACTION]$(tput sgr0)"
RESET="$(tput sgr0)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# =========================
# REPOs
# =========================
REPO_URL="https://github.com/ahmad9059/dotfiles.git"
REPO_URL_NVIM="https://github.com/ahmad9059/nvim"
TMUXIFIER_REPO="https://github.com/jimeh/tmuxifier.git"

# ======================================
# Paths: Repos, Waybar, nvim, Sddm, Grub
# ======================================
REPO_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup"
# Waybar Paths
WAYBAR_STYLE_TARGET="$HOME/.config/waybar/style.css"
CUSTOM_WAYBAR_STYLE="$HOME/.config/waybar/style/Catppuccin Mocha Custom.css"
# Neovim Paths
CONFIG_DIR="$HOME/.config/nvim"
# SDDM Theme Paths
SDDM_THEME_NAME="simple-sddm-2"
SDDM_THEME_SOURCE="$REPO_DIR/$SDDM_THEME_NAME"
SDDM_THEME_DEST="/usr/share/sddm/themes/$SDDM_THEME_NAME"
SDDM_CONF="/etc/sddm.conf"
# Grub Theme Paths
GRUB_THEME_ARCHIVE="$HOME/dotfiles/utilities/Vimix-1080p.tar.xz"
GRUB_THEME_DIR="/tmp/vimix-grub"

# =============================
# Packages list
# =============================

# Mandatory packages
REQUIRED_PACKAGES=(foot lsd bat firefox tmux yazi zoxide qt6-5compat)
# Pacman Packages (Optional)
PACMAN_PACKAGES=(
  foot alacritty lsd bat tmux neovim tldr
  obs-studio vlc yazi luacheck luarocks hyprpicker
  firefox obsidian github-cli spotify-launcher
  noto-fonts-emoji ttf-noto-nerd noto-fonts
)
# Yay Packages (Optional)
YAY_PACKAGES=(
  visual-studio-code-bin 64gram-desktop-bin vesktop
  apple-fonts foliate whatsapp-for-linux stacer-bin localsend-bin
)

# ===========================
# Ahmad's Banner
# ===========================

echo -e "\033[1;31m     _       _    __ _ _             ___           _        _ _           \033[0m"
echo -e "\033[1;32m  __| | ___ | |_ / _(_) | ___  ___  |_ _|_ __  ___| |_ __ _| | | ___ _ __ \033[0m"
echo -e "\033[1;33m / _\` |/ _ \| __| |_| | |/ _ \/ __|  | || '_ \/ __| __/ _\` | | |/ _ \ '__|\033[0m"
echo -e "\033[1;34m| (_| | (_) | |_|  _| | |  __/\__ \  | || | | \__ \ || (_| | | |  __/ |   \033[0m"
echo -e "\033[1;35m \__,_|\___/ \__|_| |_|_|\___||___/ |___|_| |_|___/\__\__,_|_|_|\___|_|   \033[0m"

# ==================================
# Ask for sudo once at the beginning
# ==================================
echo -e "${ACTION} Requesting sudo access...${RESET}"
sudo -v || {
  echo "${ERROR} Sudo failed. Exiting."
  exit 1
}

# ===========
# Clone repo
# ===========
echo -e "${ACTION} Cloning dotfiles...${RESET}"
git clone "$REPO_URL" "$REPO_DIR" || echo "${WARN} Repo already exists. Skipping clone."

# ============================
# Log file
# ============================
LOG_FILE="$HOME/install_dotfiles.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ===========================
# Backup old configs
# ===========================
echo -e "${ACTION} Backing up existing dotfiles...${RESET}"
mkdir -p "$BACKUP_DIR"
[ -d ~/.config ] && cp -r ~/.config "$BACKUP_DIR/"
[ -f ~/.zshrc ] && cp ~/.zshrc "$BACKUP_DIR/"
[ -f ~/.tmux.conf ] && cp ~/.tmux.conf "$BACKUP_DIR/"
echo -e "${OK} Backup Created ${RESET}"

# ========================================
# Remove old config folders before copying
# ========================================
echo -e "${ACTION} Removing old config folders (only those in repo)...${RESET}"
for folder in "$REPO_DIR/.config/"*; do
  folder_name=$(basename "$folder")
  if [ -d "$HOME/.config/$folder_name" ]; then
    rm -rf "$HOME/.config/$folder_name"
  fi
  echo "${OK} Old Removed Folders"
done

# =================
# Copy new dotfiles
# =================
echo -e "${ACTION} Copying new dotfiles...${RESET}"
cp -r "$REPO_DIR/.config/"* ~/.config/
cp "$REPO_DIR/.zshrc" ~/
cp "$REPO_DIR/.tmux.conf" ~/
echo -e "${OK} Personal Dotfiles Copied${RESET}"

# ==========================
# Install neovim from GitHub
# ==========================
if [ -d "$CONFIG_DIR" ]; then
  echo "${ACTION} Removing old Neovim config..."
  rm -rf "$CONFIG_DIR"
fi
echo "${ACTION} Cloning Neovim config from $REPO_URL_NVIM"
git clone "$REPO_URL_NVIM" "$CONFIG_DIR"
echo "${OK} Neovim config installed in $CONFIG_DIR"

# =======
# Themes
# =======
echo -e "${ACTION} 🎨 Installing themes...${RESET}"
mkdir -p ~/.themes
cp -r "$REPO_DIR/.themes/"* ~/.themes/
echo -e "${OK} 🎨 Themes Installed...${RESET}"

# ======
# Icons
# ======
echo -e "${ACTION} 🎨 Installing icons...${RESET}"
cp "$REPO_DIR/.icons/.icons.tar.xz" "$HOME/"
tar -xf "$HOME/.icons.tar.xz" -C "$HOME/"
rm "$HOME/.icons.tar.xz"
echo -e "${OK} 🎨 Icons Installed${RESET}"

# ============
# Waybar style
# ============
echo -e "${ACTION} Linking custom Waybar style...${RESET}"
ln -sf "$CUSTOM_WAYBAR_STYLE" "$WAYBAR_STYLE_TARGET"
if pgrep -x "waybar" >/dev/null; then
  echo -e "${ACTION} Reloading Waybar...${RESET}"
  pkill -SIGUSR2 waybar
  echo -e "${OK} Waybar Setup Completed${RESET}"
else
  echo -e "${WARN} Waybar not running. Style will apply on next launch.${RESET}"
fi

# ========================
# Setting the SDDM themes
# ========================
echo -e "${ACTION} Installing SDDM theme '$SDDM_THEME_NAME'...${RESET}"
if [ -d "$SDDM_THEME_SOURCE" ]; then
  sudo cp -r "$SDDM_THEME_SOURCE" "$SDDM_THEME_DEST"
  echo -e "${OK} SDDM theme Installed -  '$SDDM_THEME_NAME'...${RESET}"
else
  echo -e "${YELLOW} Theme folder '$SDDM_THEME_SOURCE' not found. Skipping SDDM theme copy.${RESET}"
fi
if [ ! -f "$SDDM_CONF" ]; then
  echo -e "${WARN} /etc/sddm.conf not found. Creating it...${RESET}"
  echo "[Theme]" | sudo tee "$SDDM_CONF" >/dev/null
fi
if grep -q "^\[Theme\]" "$SDDM_CONF"; then
  sudo sed -i "/^\[Theme\]/,/^\[/ s/^Current=.*/Current=$SDDM_THEME_NAME/" "$SDDM_CONF"
  if ! grep -q "^Current=" "$SDDM_CONF"; then
    sudo sed -i "/^\[Theme\]/a Current=$SDDM_THEME_NAME" "$SDDM_CONF"
  fi
else
  echo -e "\n[Theme]\nCurrent=$SDDM_THEME_NAME" | sudo tee -a "$SDDM_CONF" >/dev/null
fi
echo -e "${OK} SDDM theme set to '$SDDM_THEME_NAME'.${RESET}"

# ===============
# Gtk theme setup
# ===============
echo -e "${ACTION} Updating GTK theme settings...${RESET}"
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/gtk-4.0
echo -e "${OK} Applying GTK theme via gsettings...${RESET}"
gsettings set org.gnome.desktop.interface gtk-theme 'Material-DeepOcean-BL'
gsettings set org.gnome.desktop.interface icon-theme 'dracula-icons-main'
gsettings set org.gnome.desktop.interface cursor-theme 'Future-Black-Cursors'
gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 11'
gsettings set org.gnome.desktop.wm.preferences theme 'Material-DeepOcean-BL'
echo -e "${OK} GTK Theme, Icon, Cursor Applied...${RESET}"
if command -v nwg-look >/dev/null 2>&1; then
  echo -e "${ACTION} Exporting GTK settings to .config/gtk-*.0/settings.ini...${RESET}"
  nwg-look -x
else
  echo -e "${ACTION} nwg-look not found. Skipping export step.${RESET}"
fi

# =============================
# Grub BootLoader Theme (Vimix)
# =============================
echo -e "${ACTION} Checking for GRUB...${RESET}"
if command -v grub-install >/dev/null 2>&1 || command -v grub-mkconfig >/dev/null 2>&1; then
  echo -e "${GREEN}✔️ GRUB detected. Installing GRUB theme (Vimix)...${RESET}"
  mkdir -p "$GRUB_THEME_DIR"
  tar -xf "$GRUB_THEME_ARCHIVE" -C "$GRUB_THEME_DIR"
  if INSTALL_PATH=$(find "$GRUB_THEME_DIR" -type f -name "install.sh" -exec dirname {} \; | head -n1); then
    echo -e "${GREEN} Running install.sh from $INSTALL_PATH...${RESET}"
    pushd "$INSTALL_PATH" >/dev/null
    sudo bash ./install.sh
    popd >/dev/null
  else
    echo -e "${WARN} install.sh not found in extracted Vimix theme. Skipping GRUB theme install.${RESET}"
  fi
else
  echo -e "${WARN} GRUB not detected on system. Skipping GRUB theme installation.${RESET}"
fi

# ==========================
# Install Tmux and Tmuxifier
# ==========================
echo -e "${ACTION} Installing Tmux Plugin Manager (TPM)...${RESET}"
TPM_DIR="$HOME/.tmux/plugins/tpm"
echo -e "${ACTION} Installing tmuxifier...${RESET}"
if [ -d "$HOME/.tmuxifier" ]; then
  echo -e "${WARN} Existing ~/.tmuxifier found, removing it for a fresh install...${RESET}"
  rm -rf "$HOME/.tmuxifier"
fi
git clone "$TMUXIFIER_REPO" "$HOME/.tmuxifier"
echo -e "${OK} Official tmuxifier cloned to $HOME/.tmuxifier${RESET}"
echo -e "${ACTION} Copying custom tmuxifier layouts...${RESET}"
mkdir -p "$HOME/.tmuxifier/layouts"
cp -r "$REPO_DIR/.tmuxifier/layouts/." "$HOME/.tmuxifier/layouts/"
if [ -d "$TPM_DIR" ]; then
  echo -e "${WARN} TPM already installed at $TPM_DIR. Skipping clone.${RESET}"
else
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  echo -e "${OK} Tmux and Tmuxifier Installed${RESET}"
fi

# =================
# Wallpapers Setup
# =================

echo -e "${ACTION} Updating wallpapers and Setup...${RESET}"
WALLPAPER_SRC="$REPO_DIR/wallpapers"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
# Make sure source exists
if [ -d "$WALLPAPER_SRC" ]; then
  mkdir -p "$WALLPAPER_DIR"
  rm -rf "$WALLPAPER_DIR"/* # remove old wallpapers
  cp -r "$WALLPAPER_SRC/"* "$WALLPAPER_DIR/"
  echo -e "${OK} Wallpapers copied to $WALLPAPER_DIR${RESET}"
else
  echo -e "${WARN}  No wallpapers folder found at $WALLPAPER_SRC – skipping copy.${RESET}"
fi
# Only attempt if we’re inside a Wayland session
if [ -n "$WAYLAND_DISPLAY" ]; then
  echo -e "${ACTION} Setting wallpaper (wallpaper-1.jpg) with swww...${RESET}"
  # Start swww‑daemon if it’s not already running
  if ! pgrep -x swww-daemon >/dev/null; then
    swww-daemon &
    sleep 1 # give the daemon a second to initialise
  fi
  # Set the wallpaper
  swww img "$WALLPAPER_DIR/wallpaper-1.jpg" --transition-type any
else
  echo -e "${WARN}  Not in a Wayland session – skipping swww wallpaper setup.${RESET}"
fi

# ========================================
# Set Only Time Locale to Pakistan (Urdu)
# ========================================

echo -e "${ACTION} Setting ur_PK.UTF-8 locale for time...${RESET}"
sudo sed -i 's/^#\s*\(ur_PK.*UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
if ! grep -q "^LC_TIME=ur_PK.UTF-8" /etc/locale.conf 2>/dev/null; then
  echo "LC_TIME=ur_PK.UTF-8" | sudo tee -a /etc/locale.conf >/dev/null
fi
echo -e "${OK} LC_TIME=ur_PK.UTF-8 set successfully.${RESET}"

# =================
# Required Packages
# =================

echo -e "${ACTION} Installing required packages...${RESET}"
sudo pacman -Sy --noconfirm --needed "${REQUIRED_PACKAGES[@]}" &>/dev/null
echo -e "${ACTION} Requird Packages Installed ${RESET}"

# ==============================
# Ask to install pacman packages
# ==============================

echo -e "\n${ACTION} Do you want to install the following pacman packages?${RESET}"
echo "${PACMAN_PACKAGES[@]}"
read -rp "Type 'yes/no' to continue: " ans1
if [[ "$ans1" == "yes" ]]; then
  sudo pacman -Sy --needed "${PACMAN_PACKAGES[@]}"
  echo -e "\n${OK} Do you want to install the following pacman packages?${RESET}"
fi

# ============================
# Ask to install yay packages
# ============================

if command -v yay >/dev/null 2>&1; then
  echo -e "\n${ACTION} Do you want to install the following AUR (yay) packages?${RESET}"
  echo "${YAY_PACKAGES[@]}"
  read -rp "Type 'yes/no' to continue: " ans2
  if [[ "$ans2" == "yes" ]]; then
    yay -S --needed "${YAY_PACKAGES[@]}"
    echo -e "\n${OK} Yay Packages Instaled${RESET}"
  fi
else
  echo -e "${WARN} yay is not installed. Skipping AUR packages.${RESET}"
fi

echo -e "\n\n\n\n\n${OK} !!======= Dotfiles setup complete! =========!!${RESET}\n\n\n\n\n"
