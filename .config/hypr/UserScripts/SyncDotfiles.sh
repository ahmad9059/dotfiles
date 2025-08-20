#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m'

# Paths
REPO_DIR="$HOME/dotfiles"
NOTIF_ICON="$HOME/.config/swaync/images/ja.png"
INITIAL_BOOT_FILE="$REPO_DIR/.config/hypr/.initial_startup_done"

# Send notification
notify() {
  local title="$1"
  local message="$2"
  local urgency="$3" # low, normal, critical
  notify-send -i "$NOTIF_ICON" -u "$urgency" "$title" "$message"
}

# Error handler
on_error() {
  local exit_code=$?
  notify "Dotfiles Sync Failed" "Script exited with code $exit_code" critical
  exit $exit_code
}
trap on_error ERR

# Sync .config items that exist in repo
notify-send -a "Dotfiles Sync" -i dialog-information "Dotfiles Sync" "Sync has been started..."
echo -e "${GREEN}📁 Syncing from system to repo (for changes you made locally)...${NC}"
for item in "$REPO_DIR/.config"/*; do
  name=$(basename "$item")
  if [ -d "$HOME/.config/$name" ]; then
    rsync -av --delete "$HOME/.config/$name/" "$REPO_DIR/.config/$name/"
  elif [ -f "$HOME/.config/$name" ]; then
    cp "$HOME/.config/$name" "$REPO_DIR/.config/$name"
  fi
done

# Sync top-level items (excluding .icons)
rsync -av --delete "$HOME/.themes/" "$REPO_DIR/.themes/"

# Only sync tmuxifier layouts folder
mkdir -p "$REPO_DIR/.tmuxifier/layouts"
rsync -av --delete "$HOME/.tmuxifier/layouts/" "$REPO_DIR/.tmuxifier/layouts/"

# Other top-level configs
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$REPO_DIR/.zshrc"
[ -f "$HOME/.tmux.conf" ] && cp "$HOME/.tmux.conf" "$REPO_DIR/.tmux.conf"

echo -e "${GREEN}Local changes synced to repo.${NC}"

# === Apply custom modifications before commit/push ===

# 1. Modify kb_options in UserSettings.conf
USERS_CONF="$REPO_DIR/.config/hypr/UserConfigs/UserSettings.conf"
if [ -f "$USERS_CONF" ]; then
  sed -i 's/kb_options = ctrl:nocaps/kb_options =/' "$USERS_CONF"
fi

# 2. Update hyprland.conf label block (LC_TIME and font_family)
HYPR_CONF="$REPO_DIR/.config/hypr/hyprlock.conf"
if [ -f "$HYPR_CONF" ]; then
  sed -i 's/LC_TIME=ur_PK.UTF-8/LC_TIME=en_US.UTF-8/' "$HYPR_CONF"
  sed -i 's/Noto Nastaliq Urdu/SF Pro Display Semibold/' "$HYPR_CONF"
fi

# 3. Break the Waybar symlinks so they can be recreated later
WAYBAR_CONFIG="$REPO_DIR/.config/waybar/config"
WAYBAR_STYLE="$REPO_DIR/.config/waybar/style.css"
if [ -L "$WAYBAR_CONFIG" ]; then
  rm "$WAYBAR_CONFIG"
fi
if [ -L "$WAYBAR_STYLE" ]; then
  rm "$WAYBAR_STYLE"
fi

# Remove Hyprland initial startup marker file (if present)
if [ -f "$INITIAL_BOOT_FILE" ]; then
  rm -f "$INITIAL_BOOT_FILE"
  echo -e "${NOTE} Removed initial startup marker.${NC}"
fi

# Commit and push changes
echo -e "${GREEN}Committing and pushing changes...${NC}"
cd "$REPO_DIR"
git add .
if git commit -m "Sync local changes $(date '+%Y-%m-%d %H:%M:%S')"; then
  git push
  notify "Dotfiles Sync Completed" "Changes committed and pushed successfully" normal
else
  notify "Dotfiles Sync" "Already synced to Newest Change" low
fi
