#!/bin/bash

set -e

GREEN='\033[0;32m'
NC='\033[0m'

# Paths
REPO_DIR="$HOME/dotfiles"
NOTIF_ICON="$HOME/.config/swaync/images/ja.png"

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

# Commit and push changes
echo -e "${GREEN}Committing and pushing changes...${NC}"
cd "$REPO_DIR"
git checkout personal
git add .
if git commit -m "Sync local changes $(date '+%Y-%m-%d %H:%M:%S')"; then
  git push origin personal
  notify "Dotfiles Sync Completed" "Changes committed and pushed successfully to personal branch" normal
else
  notify -a "Dotfiles Sync" "Already synced to newest change (no new commits)" low
fi
