#!/bin/bash

set -e

# ===========================
# Color-coded status labels
# ===========================
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
WARN="$(tput setaf 3)[WARN]$(tput sgr0)"
OK="$(tput setaf 2)[OK]$(tput sgr0)"
NOTE="$(tput setaf 6)[NOTE]$(tput sgr0)"
ACTION="$(tput setaf 4)[ACTION]$(tput sgr0)"
RESET="$(tput sgr0)"

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
WAYBAR_LAYOUT_TARGET="$HOME/.config/waybar/config"
CUSTOM_WAYBAR_STYLE="$HOME/.config/waybar/style/Catppuccin Mocha Custom.css"
CUSTOM_WAYBAR_LAYOUT="$HOME/.config/waybar/configs/[TOP] Default Laptop"
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
REQUIRED_PACKAGES=(foot lsd bat firefox tmux yazi zoxide qt6-5compat npm)
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
# Log Details
# ===========================
LOG_FILE="$HOME/installer_log/install_dotfiles.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ==================================
# Ask for sudo once at the beginning
# ==================================
echo -e "${ACTION} Requesting sudo access...${RESET}"
sudo -v || {
  echo "${ERROR} Sudo failed. Exiting."
  exit 1
}

# ====================
# Clone dotfiles repo
# ====================
echo -e "${ACTION} Cloning dotfiles into ${REPO_DIR}...${RESET}"

# If repo folder already exists
if [ -d "$REPO_DIR" ]; then
  echo -e "${NOTE} Folder ${REPO_DIR} already exists. Skipping clone.${RESET}"
else
  if git clone "$REPO_URL" "$REPO_DIR" &>>"$LOG_FILE"; then
    echo -e "${OK} Dotfiles cloned successfully to ${REPO_DIR}.${RESET}"
  else
    echo -e "${ERROR} Failed to clone dotfiles repo from ${REPO_URL}.${RESET}"
    exit 1
  fi
fi

# =================
# Required Packages
# =================

echo -e "${ACTION} Installing required packages...${RESET}" | tee -a "$LOG_FILE"

# Print package list with header in blue and packages in default color
echo -e "\n\033[1;34mRequired Packages:\033[0m\n" | tee -a "$LOG_FILE"
for pkg in "${REQUIRED_PACKAGES[@]}"; do
  echo -e "  • $pkg" | tee -a "$LOG_FILE"
done
echo | tee -a "$LOG_FILE"

echo -e "${ACTION} Packages Installing in Progress...${RESET}" | tee -a "$LOG_FILE"
# Keep retrying until success
until sudo pacman -Sy --noconfirm --needed "${REQUIRED_PACKAGES[@]}" | tee -a "$LOG_FILE"; do
  echo -e "${ERROR} Failed to install required packages. Retrying...${RESET}" | tee -a "$LOG_FILE"
  sleep 2
done

echo -e "${OK} Required packages installed successfully.${RESET}" | tee -a "$LOG_FILE"

# ===========================
# Backup old configs
# ===========================
echo -e "${ACTION} Backing up existing dotfiles to ${BACKUP_DIR}...${RESET}"
# Remove existing backup if it exists
if [ -d "$BACKUP_DIR" ]; then
  echo -e "${ACTION} Existing backup found. Removing old backup...${RESET}"
  rm -rf "$BACKUP_DIR" &>>"$LOG_FILE"
fi
if mkdir -p "$BACKUP_DIR" &>>"$LOG_FILE"; then
  # Copy only if files/folders exist
  [ -d "$HOME/.config" ] && cp -r "$HOME/.config" "$BACKUP_DIR/" &>>"$LOG_FILE"
  [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/" &>>"$LOG_FILE"
  [ -f "$HOME/.tmux.conf" ] && cp "$HOME/.tmux.conf" "$BACKUP_DIR/" &>>"$LOG_FILE"

  echo -e "${OK} Backup completed and stored in ${BACKUP_DIR}.${RESET}"
else
  echo -e "${ERROR} Failed to create backup directory at ${BACKUP_DIR}.${RESET}"
  exit 1
fi

# ========================================
# Remove old config folders before copying
# ========================================
echo -e "${ACTION} Removing old config folders from ~/.config that are in ${REPO_DIR}...${RESET}"
if [ -d "$REPO_DIR/.config" ]; then
  for folder in "$REPO_DIR/.config/"*; do
    folder_name=$(basename "$folder")
    if [ -d "$HOME/.config/$folder_name" ]; then
      rm -rf "$HOME/.config/$folder_name" &>>"$LOG_FILE"
    fi
  done
  echo -e "${OK} Old config folders removed successfully.${RESET}"
else
  echo -e "${WARN} No .config folder found in ${REPO_DIR}, skipping removal.${RESET}"
fi

# =================
# Copy new dotfiles
# =================
echo -e "${ACTION} Copying new dotfiles...${RESET}"

if [ -d "$REPO_DIR/.config" ]; then
  mkdir -p ~/.config
  {
    cp -r "$REPO_DIR/.config/"* ~/.config/
    cp "$REPO_DIR/.zshrc" ~/
    cp "$REPO_DIR/.tmux.conf" ~/
  } >>"$LOG_FILE" 2>&1

  if [ $? -eq 0 ]; then
    echo -e "${OK} Personal dotfiles copied successfully.${RESET}"
  else
    echo -e "${ERROR} Failed to copy one or more dotfiles. Check $LOG_FILE for details.${RESET}"
  fi
else
  echo -e "${ERROR} '$REPO_DIR/.config' does not exist. Dotfiles not copied.${RESET}"
fi

# ==========================
# Install Neovim from GitHub
# ==========================
echo -e "${ACTION} Installing Neovim config from ${REPO_URL_NVIM}...${RESET}" | tee -a "$LOG_FILE"
if [ -d "$CONFIG_DIR" ]; then
  rm -rf "$CONFIG_DIR" >>"$LOG_FILE" 2>&1
fi
if git clone "$REPO_URL_NVIM" "$CONFIG_DIR" >>"$LOG_FILE" 2>&1; then
  echo -e "${OK} Neovim config installed in ${CONFIG_DIR}.${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${ERROR} Failed to clone Neovim config from ${REPO_URL_NVIM}.${RESET}" | tee -a "$LOG_FILE"
  exit 1
fi
echo -e "${ACTION} Installing and Setting Up Neovim Lazy, Mason Packages...${RESET}" | tee -a "$LOG_FILE"
rm -rf "$CONFIG_DIR/.git" >>"$LOG_FILE" 2>&1
nvim --headless -c 'qa' >>"$LOG_FILE" 2>&1
nvim --headless -c 'Lazy sync' -c 'qa' >>"$LOG_FILE" 2>&1
echo -e "${OK} NvChad, plugins, and Mason packages installed successfully!${RESET}" | tee -a "$LOG_FILE"

# =========================
# Themes
# =========================
echo -e "${ACTION} Installing themes from ${REPO_DIR}/.themes...${RESET}"

if [ -d "$REPO_DIR/.themes" ]; then
  mkdir -p "$HOME/.themes" &>>"$LOG_FILE"
  cp -r "$REPO_DIR/.themes/"* "$HOME/.themes/" &>>"$LOG_FILE"
  echo -e "${OK} Themes installed successfully in ~/.themes.${RESET}"
else
  echo -e "${WARN} No .themes directory found in ${REPO_DIR}, skipping theme installation.${RESET}"
fi

# ==============================
# Icons
# ==============================
if command -v yay >/dev/null 2>&1; then
  echo -e "${ACTION} Installing 'papirus-icon-theme' via yay...${RESET}"
  if yay -S --needed --noconfirm papirus-icon-theme >>"$LOG_FILE" 2>&1; then
    echo -e "${OK} 'papirus-icon-theme' installed successfully.${RESET}"
  else
    echo -e "${ERROR} Failed to install 'papirus-icon-theme'. Check $LOG_FILE for details.${RESET}"
  fi
else
  echo -e "${WARN} yay not found. Skipping 'papirus-icon-theme' installation.${RESET}"
fi

# =============================
# Waybar style
# =============================
echo -e "${ACTION} Linking custom Waybar style...${RESET}"

if [ -f "$CUSTOM_WAYBAR_STYLE" ]; then
  ln -sf "$CUSTOM_WAYBAR_LAYOUT" "$WAYBAR_LAYOUT_TARGET" &>>"$LOG_FILE"
  ln -sf "$CUSTOM_WAYBAR_STYLE" "$WAYBAR_STYLE_TARGET" &>>"$LOG_FILE"

  if pgrep -x "waybar" &>/dev/null; then
    pkill -SIGUSR2 waybar &>>"$LOG_FILE"
    echo -e "${OK} Waybar style applied and reloaded.${RESET}"
  else
    echo -e "${WARN} Waybar not running. Style will apply on next launch.${RESET}"
  fi
else
  echo -e "${WARN} Custom Waybar style not found at ${CUSTOM_WAYBAR_STYLE}, skipping.${RESET}"
fi

# ========================
# Setting the SDDM theme
# ========================
echo -e "${ACTION} Setting SDDM theme to '$SDDM_THEME_NAME'...${RESET}"

# Install theme if source exists
if [ -d "$SDDM_THEME_SOURCE" ]; then
  sudo cp -r "$SDDM_THEME_SOURCE" "$SDDM_THEME_DEST" &>>"$LOG_FILE"
  echo -e "${OK} SDDM theme '$SDDM_THEME_NAME' installed.${RESET}"
else
  echo -e "${YELLOW} Theme folder '$SDDM_THEME_SOURCE' not found. Skipping theme installation.${RESET}"
fi

# Ensure config file exists
if [ ! -f "$SDDM_CONF" ]; then
  echo -e "${WARN} '$SDDM_CONF' not found. Creating it...${RESET}"
  echo "[Theme]" | sudo tee "$SDDM_CONF" &>>"$LOG_FILE"
fi

# Update or add Current= line
if grep -q "^\[Theme\]" "$SDDM_CONF"; then
  sudo sed -i "/^\[Theme\]/,/^\[/ s/^Current=.*/Current=$SDDM_THEME_NAME/" "$SDDM_CONF" &>>"$LOG_FILE"
  if ! grep -q "^Current=" "$SDDM_CONF"; then
    sudo sed -i "/^\[Theme\]/a Current=$SDDM_THEME_NAME" "$SDDM_CONF" &>>"$LOG_FILE"
  fi
else
  echo -e "\n[Theme]\nCurrent=$SDDM_THEME_NAME" | sudo tee -a "$SDDM_CONF" &>>"$LOG_FILE"
fi

echo -e "${OK} SDDM theme successfully set to '$SDDM_THEME_NAME'.${RESET}"

# ===============
# Gtk theme setup
# ===============
echo -e "${ACTION} Updating GTK theme settings...${RESET}" | tee -a "$LOG_FILE"

{
  mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

  gsettings set org.gnome.desktop.interface gtk-theme 'Material-DeepOcean-BL'
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
  gsettings set org.gnome.desktop.interface cursor-theme 'Future-Black-Cursors'
  gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 11'
  gsettings set org.gnome.desktop.wm.preferences theme 'Material-DeepOcean-BL'

  echo -e "${OK} GTK Theme, Icon, and Cursor applied.${RESET}"
} >>"$LOG_FILE" 2>&1

if command -v nwg-look >/dev/null 2>&1; then
  echo -e "${ACTION} Exporting GTK settings to settings.ini...${RESET}" | tee -a "$LOG_FILE"
  nwg-look -x >>"$LOG_FILE" 2>&1
else
  echo -e "${WARN} nwg-look not found. Skipping export step.${RESET}" | tee -a "$LOG_FILE"
fi

# =============================
# Grub BootLoader Theme (Vimix)
# =============================
echo -e "${ACTION} Checking for GRUB...${RESET}"

if command -v grub-install >/dev/null 2>&1 || command -v grub-mkconfig >/dev/null 2>&1; then
  echo -e "${OK} GRUB detected. Installing GRUB theme (Vimix)...${RESET}"

  mkdir -p "$GRUB_THEME_DIR"
  tar -xf "$GRUB_THEME_ARCHIVE" -C "$GRUB_THEME_DIR"

  INSTALL_PATH=$(find "$GRUB_THEME_DIR" -type f -name "install.sh" -exec dirname {} \; | head -n1)
  if [ -n "$INSTALL_PATH" ]; then
    echo -e "${ACTION} Running GRUB theme installer...${RESET}"
    pushd "$INSTALL_PATH" >/dev/null
    sudo bash ./install.sh >/dev/null 2>&1
    popd >/dev/null
    echo -e "${OK} GRUB theme installed successfully.${RESET}"
  else
    echo -e "${WARN} install.sh not found in extracted Vimix theme. Skipping.${RESET}"
  fi
else
  echo -e "${WARN} GRUB not detected. Skipping GRUB theme installation.${RESET}"
fi

# ==========================
# Install Tmux and Tmuxifier
# ==========================

# Show ACTION only once
echo -e "${ACTION} Installing Tmux Plugin Manager (TPM) and tmuxifier...${RESET}"

TPM_DIR="$HOME/.tmux/plugins/tpm"

# Tmuxifier installation
if [ -d "$HOME/.tmuxifier" ]; then
  echo -e "${WARN} Existing ~/.tmuxifier found, removing it for a fresh install...${RESET}"
  rm -rf "$HOME/.tmuxifier"
fi
git clone "$TMUXIFIER_REPO" "$HOME/.tmuxifier"

# Show OK only once
echo -e "${OK} Official tmuxifier cloned to $HOME/.tmuxifier${RESET}"

# Copy layouts
mkdir -p "$HOME/.tmuxifier/layouts"
cp -r "$REPO_DIR/.tmuxifier/layouts/." "$HOME/.tmuxifier/layouts/"

# TPM installation
if [ -d "$TPM_DIR" ]; then
  echo -e "${WARN} TPM already installed at $TPM_DIR. Skipping clone.${RESET}"
else
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# =================================================
# Remove only the first \n inside the print -P line
# =================================================

echo -e "${ACTION} Removing leading \\n from print -P line in refined theme...${RESET}" | tee -a "$LOG_FILE"

if sed -i 's/print -P "\\n\(.*\)"/print -P "\1"/' ~/.oh-my-zsh/themes/refined.zsh-theme; then
  echo -e "${OK} Successfully removed leading \\n from refined.zsh-theme.${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${ERROR} Failed to update refined.zsh-theme.${RESET}" | tee -a "$LOG_FILE"
  exit 1
fi

# =================
# Wallpapers Setup
# =================
echo -e "${ACTION} Updating wallpapers and Setup...${RESET}"
WALLPAPER_SRC="$REPO_DIR/wallpapers"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

if [ -d "$WALLPAPER_SRC" ]; then
  mkdir -p "$WALLPAPER_DIR"
  rm -rf "$WALLPAPER_DIR"/*
  cp -r "$WALLPAPER_SRC/"* "$WALLPAPER_DIR/"
  echo -e "${OK} Wallpapers copied to $WALLPAPER_DIR${RESET}"
else
  echo -e "${WARN} No wallpapers folder found at $WALLPAPER_SRC – skipping copy.${RESET}"
fi

if [ -n "$WAYLAND_DISPLAY" ]; then
  # Start swww-daemon if it’s not already running
  if ! pgrep -x swww-daemon >/dev/null; then
    swww-daemon &
    sleep 1
  fi
  swww img "$WALLPAPER_DIR/wallpaper-1.jpg" --transition-type any
else
  # WARN already shown above, so this one is suppressed
  :
fi

# ==============================
# Ask to install pacman packages
# ==============================
echo -e "\n${ACTION} Do you want to install the following pacman packages?${RESET}"

# Print package list with header in blue and packages in default color
echo -e "\n\033[1;34mPacman Packages (Optional):\033[0m\n" | tee -a "$LOG_FILE"
for pkg in "${PACMAN_PACKAGES[@]}"; do
  echo -e "  • $pkg" | tee -a "$LOG_FILE"
done
echo | tee -a "$LOG_FILE"

# Keep asking until valid input
while true; do
  read -rp "Type 'yes' or 'no' to continue: " ans1
  case "${ans1,,}" in # convert input to lowercase
  yes | y)
    echo -e "${ACTION} Installing pacman packages...${RESET}" | tee -a "$LOG_FILE"
    echo -e "${NOTE} Installing packages in progress...${RESET}" | tee -a "$LOG_FILE"

    # Retry logic
    MAX_RETRIES=3
    RETRY_DELAY=5
    count=0
    while [ $count -lt $MAX_RETRIES ]; do
      if sudo pacman -Sy --needed "${PACMAN_PACKAGES[@]}" | tee -a "$LOG_FILE"; then
        echo -e "${OK} Pacman packages installed successfully.${RESET}" | tee -a "$LOG_FILE"
        break
      else
        count=$((count + 1))
        echo -e "${WARN} Installation failed. Retry $count of $MAX_RETRIES in $RETRY_DELAY seconds...${RESET}" | tee -a "$LOG_FILE"
        sleep $RETRY_DELAY
      fi
    done

    if [ $count -eq $MAX_RETRIES ]; then
      echo -e "${ERROR} Failed to install pacman packages after $MAX_RETRIES attempts. See $LOG_FILE for details.${RESET}" | tee -a "$LOG_FILE"
      exit 1
    fi

    break
    ;;
  no | n)
    echo -e "${NOTE} Skipped installing pacman packages.${RESET}" | tee -a "$LOG_FILE"
    break
    ;;
  *)
    echo -e "${ERROR} Invalid input. Please type 'yes' or 'no'.${RESET}"
    ;;
  esac
done

# ============================
# Ask to install yay packages
# ============================

if command -v yay >/dev/null 2>&1; then
  echo -e "\n${ACTION} Do you want to install the following AUR (yay) packages?${RESET}"
  echo -e "\n\033[1;34mYay Packages:\033[0m\n" | tee -a "$LOG_FILE"
  for pkg in "${YAY_PACKAGES[@]}"; do
    echo -e "  • $pkg" | tee -a "$LOG_FILE"
  done
  echo | tee -a "$LOG_FILE"
  while true; do
    read -rp "Type 'yes' or 'no' to continue: " ans2
    case "${ans2,,}" in # convert input to lowercase
    yes | y)
      echo -e "${ACTION} Installing AUR packages...${RESET}" | tee -a "$LOG_FILE"
      echo -e "${NOTE} Installing packages in progress...${RESET}" | tee -a "$LOG_FILE"
      MAX_RETRIES=5
      RETRY_DELAY=5
      count=0
      while [ $count -lt $MAX_RETRIES ]; do
        if yay -S --needed "${YAY_PACKAGES[@]}" | tee -a "$LOG_FILE"; then
          echo -e "${OK} AUR packages installed successfully.${RESET}" | tee -a "$LOG_FILE"
          break
        else
          count=$((count + 1))
          echo -e "${WARN} Installation failed. Retry $count of $MAX_RETRIES in $RETRY_DELAY seconds...${RESET}" | tee -a "$LOG_FILE"
          sleep $RETRY_DELAY
        fi
      done
      if [ $count -eq $MAX_RETRIES ]; then
        echo -e "${ERROR} Failed to install AUR packages after $MAX_RETRIES attempts. See $LOG_FILE for details.${RESET}" | tee -a "$LOG_FILE"
        exit 1
      fi
      break
      ;;
    no | n)
      echo -e "${NOTE} Skipped installing AUR packages.${RESET}" | tee -a "$LOG_FILE"
      break
      ;;
    *)
      echo -e "${ERROR} Invalid input. Please type 'yes' or 'no'.${RESET}"
      ;;
    esac
  done
else
  echo -e "${WARN} yay is not installed. Skipping AUR packages.${RESET}" | tee -a "$LOG_FILE"
fi

echo -e "\n\n${OK} !!======= Dotfiles setup complete! =========!!${RESET}\n\n"
