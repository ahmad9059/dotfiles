#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}🎨 Updating GTK theme settings...${NC}"

# Create config directories if not exist
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/gtk-4.0

# GTK 3.0 settings
cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Andromeda-dark
gtk-icon-theme-name=dracula-icons-main
gtk-font-name=Adwaita Sans 11
gtk-cursor-theme-name=Future-black-cursors
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
EOF

# GTK 4.0 settings
cat <<EOF > ~/.config/gtk-4.0/settings.ini
[Settings]
gtk-theme-name=Andromeda-dark
gtk-icon-theme-name=dracula-icons-main
gtk-font-name=Adwaita Sans 11
gtk-cursor-theme-name=Future-black-cursors
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF

echo -e "${GREEN}✅ GTK settings applied successfully!${NC}"
