#!/bin/bash

set -e

REPO_DIR="$HOME/dotfiles"

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}📁 Syncing from system to repo (for changes you made locally)...${NC}"

# Sync .config items that exist in repo
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

echo -e "${GREEN}✅ Local changes synced to repo.${NC}"

echo -e "${GREEN}⬆️ Committing and pushing changes...${NC}"
cd "$REPO_DIR"
git add .
git commit -m "Sync local changes $(date '+%Y-%m-%d %H:%M:%S')" || echo "No changes to commit."
git push
