#!/bin/bash
set -Eeuo pipefail

# Notification icon
NOTIF_ICON="$HOME/.config/swaync/images/ja.png"

# Error handler
on_error() {
    local exit_code=$?
    local last_command=${BASH_COMMAND}
    notify-send -e -u critical -i "$NOTIF_ICON" "❌ Dotfiles Sync Failed" "Command \`$last_command\` failed with exit code $exit_code."
    exit $exit_code
}
trap on_error ERR

# Repo path
REPO_DIR="$HOME/dotfiles"

GREEN='\033[0;32m'
NC='\033[0m'

notify() {
    notify-send -e -u low -i "$NOTIF_ICON" "Dotfiles Sync" "$1"
}

notify "Starting dotfiles sync..."
echo -e "${GREEN}📁 Syncing from system to repo...${NC}"

# Sync .config items that exist in repo
for item in "$REPO_DIR/.config"/*; do
    name=$(basename "$item")
    if [ -d "$HOME/.config/$name" ]; then
        rsync -av --delete "$HOME/.config/$name/" "$REPO_DIR/.config/$name/"
        notify "Synced .config/$name"
    elif [ -f "$HOME/.config/$name" ]; then
        cp "$HOME/.config/$name" "$REPO_DIR/.config/$name"
        notify "Synced file .config/$name"
    fi
done

# Sync top-level items (excluding .icons)
rsync -av --delete "$HOME/.themes/" "$REPO_DIR/.themes/"
notify "Synced ~/.themes"

# Only sync tmuxifier layouts folder
mkdir -p "$REPO_DIR/.tmuxifier/layouts"
rsync -av --delete "$HOME/.tmuxifier/layouts/" "$REPO_DIR/.tmuxifier/layouts/"
notify "Synced tmuxifier layouts"

# Other top-level configs
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$REPO_DIR/.zshrc" && notify "Synced .zshrc"
[ -f "$HOME/.tmux.conf" ] && cp "$HOME/.tmux.conf" "$REPO_DIR/.tmux.conf" && notify "Synced .tmux.conf"

echo -e "${GREEN}✅ Local changes synced to repo.${NC}"
notify "Local changes synced"

# Git commit and push
echo -e "${GREEN}⬆️ Committing and pushing changes...${NC}"
cd "$REPO_DIR"
git add .

if git diff --cached --quiet; then
    notify "No changes to commit"
else
    git commit -m "Sync local changes $(date '+%Y-%m-%d %H:%M:%S')"
    notify "Committed changes"
fi

git push && notify "Pushed to remote"

# ✅ Success notification
notify-send -e -u low -i "$NOTIF_ICON" "✅ Dotfiles Sync Completed" "Your dotfiles have been synced and pushed to GitHub."
