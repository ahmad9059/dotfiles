#!/bin/bash

MOUNT_DIR="$HOME/gdrive"

# Ensure mount directory exists
mkdir -p "$MOUNT_DIR"

# Function to check if rclone mount is active
is_mounted() {
  mount | grep -q "on $MOUNT_DIR type fuse.rclone"
}

# Check if already mounted
if is_mounted; then
  notify-send -a "Rclone Mount" -i dialog-information "Google Drive" "Already mounted at $MOUNT_DIR ✅"
  exit 0
fi

# Notify start
notify-send -a "Rclone Mount" -i folder-remote "Google Drive" "Mounting started..."

# Start rclone mount in background
rclone mount gdrive: "$MOUNT_DIR" --vfs-cache-mode writes &
disown

# Give it a moment
sleep 3

# Verify again
if is_mounted; then
  notify-send -a "Rclone Mount" -i dialog-apply "Google Drive" "Mounted successfully at $MOUNT_DIR ✅"
else
  notify-send -a "Rclone Mount" -u critical -i dialog-error "Google Drive Mount Failed" "Mount process may have failed ❌"
fi
