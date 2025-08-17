#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

# Paths
REPO_DIR="${REPO_DIR:-$HOME/dotfiles}"
NOTIF_ICON="$HOME/.config/swaync/images/ja.png"

# Send notification
notify() {
  local title="$1"
  local message="$2"
  local urgency="${3:-normal}" # low, normal, critical
  notify-send -i "$NOTIF_ICON" -u "$urgency" "$title" "$message"
}

# Error handler
on_error() {
  local exit_code=$?
  notify "Dotfiles Sync Failed" "Script exited with code $exit_code" critical
  exit $exit_code
}
trap on_error ERR

# Notify start
notify "Dotfiles Sync" "Sync has been started..." normal
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
rsync -av --delete "$HOME/.themes/" "$REPO_DIR/.themes/" || true

# Only sync tmuxifier layouts folder
mkdir -p "$REPO_DIR/.tmuxifier/layouts"
rsync -av --delete "$HOME/.tmuxifier/layouts/" "$REPO_DIR/.tmuxifier/layouts/" || true

# Other top-level configs
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$REPO_DIR/.zshrc"
[ -f "$HOME/.tmux.conf" ] && cp "$HOME/.tmux.conf" "$REPO_DIR/.tmux.conf"

# ---- Custom modifications before syncing ----

# 1) kb_options change in Hypr UserSettings.conf
HYPR_USR_SETTINGS="$REPO_DIR/.config/hypr/UserConfigs/UserSettings.conf"
if [ -f "$HYPR_USR_SETTINGS" ]; then
  cp -a "$HYPR_USR_SETTINGS" "$HYPR_USR_SETTINGS.bak" || true
  # Use python to safely edit multiline and patterns
  python3 - "$HYPR_USR_SETTINGS" <<'PY' || {
import re,sys
p=sys.argv[1]
s=open(p,'r',encoding='utf-8').read()
# Replace any kb_options line with an empty value
s = re.sub(r'(?m)^\s*kb_options\s*=.*$', 'kb_options = ""', s)
open(p,'w',encoding='utf-8').write(s)
PY
    echo "python edit failed"
    exit 1
  }
  echo -e "${GREEN}Updated kb_options in $HYPR_USR_SETTINGS (backup saved as .bak).${NC}"
else
  echo "No Hypr UserSettings.conf found at $HYPR_USR_SETTINGS — skipping kb_options change."
fi

# 2) Replace the specific label { ... } block that contains LC_TIME=ur_PK with the new block
if [ -f "$HYPR_USR_SETTINGS" ]; then
  cp -a "$HYPR_USR_SETTINGS" "$HYPR_USR_SETTINGS.label.bak" || true
  python3 - "$HYPR_USR_SETTINGS" <<'PY' || {
import re,sys
p=sys.argv[1]
s=open(p,'r',encoding='utf-8').read()
new_block = (
"label {\n"
"    monitor =\n"
"    text = cmd[update:1000] echo -e \"$(LC_TIME=en_US.UTF-8 date +\"%A, %B %d\")\"\n"
"    color = rgba(216, 222, 233, 0.90)\n"
"    font_size = 25\n"
"    font_family = SF Pro Display Semibold\n"
"    position = 0, 350\n"
"    halign = center\n"
"    valign = center\n"
"}"
)
# Replace any label { ... } block that contains 'LC_TIME=ur_PK' (non-greedy)
pattern = re.compile(r'label\s*{\s*.*?LC_TIME=ur_PK.*?}', re.S)
if pattern.search(s):
    s2 = pattern.sub(new_block, s)
    open(p,'w',encoding='utf-8').write(s2)
else:
    # If not found, do nothing (keeps original)
    open(p,'w',encoding='utf-8').write(s)
PY
    echo "python label edit failed"
    exit 1
  }
  echo -e "${GREEN}Replaced label block (if matched) in $HYPR_USR_SETTINGS (backup saved as .label.bak).${NC}"
fi

# 3) Break and (re)create the waybar links as requested
WAYBAR_DIR="$REPO_DIR/.config/waybar"
CONFIG_LINK="$WAYBAR_DIR/config"
STYLE_LINK="$WAYBAR_DIR/style.css"

TARGET_CONFIG="$WAYBAR_DIR/configs/[TOP] Default Laptop"
TARGET_STYLE="$WAYBAR_DIR/style/Catppuccin Mocha Custom.css"

# Ensure directories exist so we can safely create links
mkdir -p "$(dirname "$TARGET_CONFIG")" "$(dirname "$TARGET_STYLE")"

# Remove any existing link/file for config and style.css in repo waybar dir
if [ -L "$CONFIG_LINK" ] || [ -e "$CONFIG_LINK" ]; then
  rm -rf "$CONFIG_LINK"
fi
if [ -L "$STYLE_LINK" ] || [ -e "$STYLE_LINK" ]; then
  rm -rf "$STYLE_LINK"
fi

# Ensure target files exist (touch if missing) so symlinks won't be dangling in git
[ -e "$TARGET_CONFIG" ] || touch "$TARGET_CONFIG"
[ -e "$TARGET_STYLE" ] || touch "$TARGET_STYLE"

# Create/new symlinks (force)
ln -sfn "$TARGET_CONFIG" "$CONFIG_LINK"
ln -sfn "$TARGET_STYLE" "$STYLE_LINK"

echo -e "${GREEN}Waybar links updated:
  $CONFIG_LINK -> $TARGET_CONFIG
  $STYLE_LINK  -> $TARGET_STYLE
(If targets were missing, empty files were created.)${NC}"

# ---- End custom modifications ----

echo -e "${GREEN}Local changes synced to repo.${NC}"

# Commit and push changes
echo -e "${GREEN}Committing and pushing changes...${NC}"
cd "$REPO_DIR"
git add .
if git commit -m "Sync local changes $(date '+%Y-%m-%d %H:%M:%S')"; then
  git push
  notify "Dotfiles Sync Completed" "Changes committed and pushed successfully" normal
else
  notify "Dotfiles Sync" "Already synced to newest change" low
fi
