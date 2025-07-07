#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

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
