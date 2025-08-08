#!/bin/bash

# GDK BACKEND. Change to either wayland or x11 if having issues
BACKEND=wayland

# Kill rofi or yad if already running
if pidof rofi > /dev/null; then pkill rofi; fi
if pidof yad > /dev/null; then pkill yad; fi

# Launch yad cheat sheet
GDK_BACKEND=$BACKEND yad \
    --center \
    --title="KooL Quick Cheat Sheet" \
    --no-buttons \
    --list \
    --column=Key: \
    --column=Description: \
    --column=Command: \
    --timeout-indicator=bottom \
"ESC" "Close this app" "" \
"SUPER + D" "Open Rofi" "pkill rofi" \
"SUPER + Return" "Open default terminal" "foot" \
"SUPER + F" "Open Thunar file manager" "thunar" \
"SUPER + K" "Launch Kitty terminal" "kitty" \
"SUPER + B" "Launch Firefox browser" "firefox" \
"SUPER + R" "Launch Foliate eBook reader" "foliate" \
"SUPER + V" "Clipboard manager" "\$scriptsDir/ClipManager.sh" \
"SUPER + C" "Launch Visual Studio Code" "code --ozone-platform=x11" \
"SUPER + O" "Launch Obsidian" "obsidian --ozone-platform=x11" \
"SUPER + S" "Launch Spotify" "spotify-launcher" \
"SUPER + I" "Launch Vesktop (Discord)" "vesktop" \
"SUPER + T" "Launch Telegram client" "(64gram-desktop|telegram-desktop)" \
"SUPER + M" "Launch Free Download Manager" "fdm" \
"SUPER + Shift + H" "Show help / cheat sheet" "\$scriptsDir/KeyHints.sh" \
"SUPER + Shift + R" "Refresh Waybar, swaync, rofi" "\$scriptsDir/Refresh.sh" \
"SUPER + Shift + E" "Open emoji picker" "\$scriptsDir/RofiEmoji.sh" \
"SUPER + Shift + O" "Toggle blur settings" "\$scriptsDir/ChangeBlur.sh" \
"SUPER + Shift + G" "Toggle animations" "\$scriptsDir/GameMode.sh" \
"SUPER + Shift + L" "Toggle layout Master/Dwindle" "\$scriptsDir/ChangeLayout.sh" \
"SUPER + Shift + P" "Color picker" "hyprpicker -a --autocopy" \
"SUPER + Shift + V" "Start yazi in foot" "systemd-run --user --scope \$scriptsDir/parrotOS-KVM.sh" \
"SUPER + Shift + B" "Hugo blog file sync" "/home/ahmad/Documents/blog/quickScript.sh" \
"SUPER + Shift + F" "Toggle fullscreen" "fullscreen" \
"SUPER + Shift + Return" "Dropdown floating terminal" "[float; move 15% 20% size 70% 60%] foot" \
"SUPER + Ctrl + F" "Fake fullscreen" "fullscreen, 1" \
"SUPER + Space" "Toggle floating mode for window" "togglefloating" \
"SUPER + Alt + Space" "Set all windows to floating" "hyprctl dispatch workspaceopt allfloat" \
"SUPER + Alt + Mouse Down" "Zoom in" "cursor zoom ×2" \
"SUPER + Alt + Mouse Up" "Zoom out" "cursor zoom ÷2" \
"SUPER + Ctrl + Alt + B" "Toggle Waybar show/hide" "pkill -SIGUSR1 waybar" \
"SUPER + Ctrl + B" "Waybar styles menu" "\$scriptsDir/WaybarStyles.sh" \
"SUPER + Alt + B" "Waybar layout menu" "\$scriptsDir/WaybarLayout.sh" \
"SUPER + Shift + M" "Play music via Rofi" "\$UserScripts/RofiBeats.sh" \
"SUPER + Shift + W" "Wallpaper selection menu" "\$UserScripts/WallpaperSelect.sh" \
"CTRL + Alt + W" "Set random wallpaper" "\$UserScripts/WallpaperRandom.sh" \
"SUPER + Ctrl + O" "Toggle window opacity" "hyprctl setprop active opaque toggle" \
"SUPER + Shift + K" "Search keybinds via Rofi" "\$scriptsDir/KeyBinds.sh" \
"SUPER + Shift + A" "Hyprland animations menu" "\$scriptsDir/Animations.sh" \
"SUPER + Alt + C" "Calculator via Rofi" "\$UserScripts/RofiCalc.sh" \
"CTRL + ALT + Delete" "Exit Hyprland" "hyprctl dispatch exit 0" \
"SUPER + Q" "Close active window" "killactive" \
"SUPER + Shift + Q" "Kill active process" "KillActiveProcess.sh" \
"CTRL + ALT + L" "Lock screen" "LockScreen.sh" \
"CTRL + ALT + P" "Power menu" "Wlogout.sh" \
"SUPER + N" "Notification panel" "swaync-client -t -sw" \
"SUPER + Ctrl + D" "Remove master" "layoutmsg removemaster" \
"SUPER + I" "Add master" "layoutmsg addmaster" \
"SUPER + J" "Cycle to next window" "layoutmsg cyclenext" \
"SUPER + K" "Cycle to previous window" "layoutmsg cycleprev" \
"SUPER + Ctrl + Return" "Swap with master" "layoutmsg swapwithmaster" \
"SUPER + Shift + I" "Toggle split (dwindle layout)" "togglesplit" \
"SUPER + P" "Toggle pseudo mode" "pseudo" \
"SUPER + M" "Set split ratio 0.3" "hyprctl dispatch splitratio 0.3" \
"SUPER + G" "Toggle group" "togglegroup" \
"SUPER + Ctrl + Tab" "Change group focus" "changegroupactive" \
"SUPER + Print" "Screenshot now" "ScreenShot.sh --now" \
"SUPER + Shift + Print" "Screenshot area" "ScreenShot.sh --area" \
"SUPER + Ctrl + Print" "Screenshot after 5s" "ScreenShot.sh --in5" \
"SUPER + Ctrl + Shift + Print" "Screenshot after 10s" "ScreenShot.sh --in10" \
"ALT + Print" "Screenshot active window" "ScreenShot.sh --active" \
"SUPER + Shift + S" "Screenshot with swappy" "ScreenShot.sh --swappy" \
"SUPER + Shift + Left" "Resize left" "resizeactive -50 0" \
"SUPER + Shift + Right" "Resize right" "resizeactive 50 0" \
"SUPER + Shift + Up" "Resize up" "resizeactive 0 -50" \
"SUPER + Shift + Down" "Resize down" "resizeactive 0 50" \
"SUPER + Ctrl + Left" "Move window left" "movewindow l" \
"SUPER + Ctrl + Right" "Move window right" "movewindow r" \
"SUPER + Ctrl + Up" "Move window up" "movewindow u" \
"SUPER + Ctrl + Down" "Move window down" "movewindow d" \
"SUPER + Alt + Left" "Swap window left" "swapwindow l" \
"SUPER + Alt + Right" "Swap window right" "swapwindow r" \
"SUPER + Alt + Up" "Swap window up" "swapwindow u" \
"SUPER + Alt + Down" "Swap window down" "swapwindow d" \
"SUPER + Left" "Move focus left" "movefocus l" \
"SUPER + Right" "Move focus right" "movefocus r" \
"SUPER + Up" "Move focus up" "movefocus u" \
"SUPER + Down" "Move focus down" "movefocus d" \
"SUPER + Tab" "Next workspace" "workspace m+1" \
"SUPER + Shift + Tab" "Previous workspace" "workspace m-1" \
"SUPER + U" "Toggle special workspace 'nyx'" "togglespecialworkspace nyx" \
"SUPER + Shift + U" "Move window to special workspace 'nyx'" "movetoworkspace special:nyx" \
"SUPER + 1-10" "Switch to workspace 1-10" "workspace 1-10" \
"SUPER + Shift + 1-10" "Move window to workspace 1-10" "movetoworkspace 1-10" \
"SUPER + Ctrl + 1-10" "Move window to workspace silently" "movetoworkspacesilent 1-10" \
"SUPER + Mouse Scroll Down" "Next workspace" "workspace e+1" \
"SUPER + Mouse Scroll Up" "Previous workspace" "workspace e-1" \
"SUPER + ." "Next workspace" "workspace e+1" \
"SUPER + ," "Previous workspace" "workspace e-1" \
"SUPER + Left Mouse" "Move window" "movewindow" \
"SUPER + Right Mouse" "Resize window" "resizewindow"
