#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Log file
LOG_FILE="$HOME/dotfiles_setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1


# Paths
REPO_URL="https://github.com/ahmad9059/dotfiles.git"
REPO_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup"
WAYBAR_STYLE_TARGET="$HOME/.config/waybar/style.css"
CUSTOM_WAYBAR_STYLE="$HOME/.config/waybar/style/Catppuccin Mocha Custom.css"

# SDDM Theme Setup
SDDM_THEME_NAME="simple-sddm-2"
SDDM_THEME_SOURCE="$REPO_DIR/$SDDM_THEME_NAME"
SDDM_THEME_DEST="/usr/share/sddm/themes/$SDDM_THEME_NAME"
SDDM_CONF="/etc/sddm.conf"

# GRUB Theme Setup
GRUB_THEME_ARCHIVE="$HOME/dotfiles/utilities/Vimix-1080p.tar.xz"
GRUB_THEME_DIR="/tmp/vimix-grub"

PACMAN_PACKAGES=(
  foot alacritty lsd bat tmux neovim tldr
  obs-studio vlc yazi luacheck luarocks hyprpicker
  firefox obsidian github-cli discord spotify-launcher
  noto-fonts-emoji ttf-noto-nerd noto-fonts
)

# Mandatory packages
REQUIRED_PACKAGES=(foot lsd bat firefox tmux)

YAY_PACKAGES=(
  thorium-browser-bin visual-studio-code-bin 64gram-desktop-bin
  apple-fonts foliate whatsapp-for-linux
  azuredatastudio-bin stacer-bin localsend-bin wps-office-bin
)

# Clone repo
echo -e "${GREEN}📦 Cloning dotfiles...${NC}"
git clone "$REPO_URL" "$REPO_DIR" || echo "⚠️ Repo already exists. Skipping clone."

# Backup old configs
echo -e "${GREEN}📁 Backing up existing dotfiles...${NC}"
mkdir -p "$BACKUP_DIR"
[ -d ~/.config ] && cp -r ~/.config "$BACKUP_DIR/"
[ -f ~/.zshrc ] && cp ~/.zshrc "$BACKUP_DIR/"
[ -f ~/.tmux.conf ] && cp ~/.tmux.conf "$BACKUP_DIR/"

# Copy new dotfiles
echo -e "${GREEN}📄 Copying new dotfiles...${NC}"
cp -r "$REPO_DIR/.config/"* ~/.config/
cp "$REPO_DIR/.zshrc" ~/
cp "$REPO_DIR/.tmux.conf" ~/

# Themes
echo -e "${GREEN}🎨 Installing themes...${NC}"
mkdir -p ~/.themes
cp -r "$REPO_DIR/.themes/"* ~/.themes/

# Icons
echo -e "${GREEN}🎨 Installing icons...${NC}"
cp "$REPO_DIR/.icons/.icons.zip" "$HOME/"
unzip -o "$HOME/.icons.zip" -d "$HOME/"
rm "$HOME/.icons.zip"

# Waybar style
echo -e "${GREEN}🔗 Linking custom Waybar style...${NC}"
ln -sf "$CUSTOM_WAYBAR_STYLE" "$WAYBAR_STYLE_TARGET"

if pgrep -x "waybar" > /dev/null; then
  echo -e "${GREEN}🔄 Reloading Waybar...${NC}"
  pkill -SIGUSR2 waybar
else
  echo -e "${GREEN}ℹ️ Waybar not running. Style will apply on next launch.${NC}"
fi

# Setting the SDDM themes
echo -e "${GREEN}🎨 Installing SDDM theme '$SDDM_THEME_NAME'...${NC}"

# Copy theme folder to /usr/share/sddm/themes/
if [ -d "$SDDM_THEME_SOURCE" ]; then
  sudo cp -r "$SDDM_THEME_SOURCE" "$SDDM_THEME_DEST"
else
  echo -e "${YELLOW}⚠️ Theme folder '$SDDM_THEME_SOURCE' not found. Skipping SDDM theme copy.${NC}"
fi

# Ensure sddm.conf exists
if [ ! -f "$SDDM_CONF" ]; then
  echo -e "${YELLOW}ℹ️ /etc/sddm.conf not found. Creating it...${NC}"
  echo "[Theme]" | sudo tee "$SDDM_CONF" > /dev/null
fi

# Set the theme in /etc/sddm.conf
if grep -q "^\[Theme\]" "$SDDM_CONF"; then
  # Update existing 'Current=' line or add if missing
  sudo sed -i "/^\[Theme\]/,/^\[/ s/^Current=.*/Current=$SDDM_THEME_NAME/" "$SDDM_CONF"
  if ! grep -q "^Current=" "$SDDM_CONF"; then
    sudo sed -i "/^\[Theme\]/a Current=$SDDM_THEME_NAME" "$SDDM_CONF"
  fi
else
  # Append section if [Theme] doesn't exist
  echo -e "\n[Theme]\nCurrent=$SDDM_THEME_NAME" | sudo tee -a "$SDDM_CONF" > /dev/null
fi

echo -e "${GREEN}✅ SDDM theme set to '$SDDM_THEME_NAME'.${NC}"


# Gtk theme setup
echo -e "${GREEN}🎨 Updating GTK theme settings...${NC}"

# Create config directories if not exist
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/gtk-4.0

echo -e "${GREEN}🎨 Applying GTK theme via gsettings...${NC}"

# Set GTK interface preferences via gsettings
gsettings set org.gnome.desktop.interface gtk-theme 'Andromeda-dark'
gsettings set org.gnome.desktop.interface icon-theme 'dracula-icons-main'
gsettings set org.gnome.desktop.interface cursor-theme 'Future-black-cursors'
gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 11'

# Optional: if using X11, also set window manager preference (not needed for Wayland)
gsettings set org.gnome.desktop.wm.preferences theme 'Andromeda-dark'

# Export the current settings to config files (so other apps or themes can use them)
if command -v nwg-look >/dev/null 2>&1; then
  echo -e "${GREEN}💾 Exporting GTK settings to .config/gtk-*.0/settings.ini...${NC}"
  nwg-look -x
else
  echo -e "${YELLOW}⚠️ nwg-look not found. Skipping export step.${NC}"
fi

# Grub BootLoader Theme (Vimix)
echo -e "${GREEN}🧩 Checking for GRUB...${NC}"

if command -v grub-install >/dev/null 2>&1 || command -v grub-mkconfig >/dev/null 2>&1; then
  echo -e "${GREEN}✔️ GRUB detected. Installing GRUB theme (Vimix)...${NC}"

  # Extract the archive
  mkdir -p "$GRUB_THEME_DIR"
  tar -xf "$GRUB_THEME_ARCHIVE" -C "$GRUB_THEME_DIR"

  # Find and run the install.sh
  if INSTALL_PATH=$(find "$GRUB_THEME_DIR" -type f -name "install.sh" -exec dirname {} \; | head -n1); then
    echo -e "${GREEN}🚀 Running install.sh...${NC}"
    bash "$INSTALL_PATH/install.sh"
  else
    echo -e "${YELLOW}⚠️ install.sh not found in extracted Vimix theme. Skipping GRUB theme install.${NC}"
  fi
else
  echo -e "${YELLOW}⚠️ GRUB not detected on system. Skipping GRUB theme installation.${NC}"
fi


#Required Packages
echo -e "${GREEN}📥 Installing required packages...${NC}"
sudo pacman -Syu --needed "${REQUIRED_PACKAGES[@]}"

# Ask to install pacman packages
echo -e "\n${YELLOW}📦 Do you want to install the following pacman packages?${NC}"
echo "${PACMAN_PACKAGES[@]}"
read -rp "Type 'yes' to continue: " ans1
if [[ "$ans1" == "yes" ]]; then
  sudo pacman -Syu --needed "${PACMAN_PACKAGES[@]}"
fi

# Ask to install yay packages
if command -v yay >/dev/null 2>&1; then
  echo -e "\n${YELLOW}📦 Do you want to install the following AUR (yay) packages?${NC}"
  echo "${YAY_PACKAGES[@]}"
  read -rp "Type 'yes' to continue: " ans2
  if [[ "$ans2" == "yes" ]]; then
    yay -S --needed "${YAY_PACKAGES[@]}"
  fi
else
  echo -e "${YELLOW}⚠️ yay is not installed. Skipping AUR packages.${NC}"
fi

echo -e "${GREEN}✅ Dotfiles setup complete!${NC}"
