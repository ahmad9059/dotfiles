#!/bin/bash

# Define variables
SRC="$HOME/Documents"
DST="gdrive:Documents"

# Notify sync start
notify-send -a "Rclone Sync" -i folder-sync "Document Sync" "Sync started..."
echo "Rclone Sync Started of Document folder"
# Run rclone sync and capture error
if rclone sync "$SRC" "$DST" --progress 2>/tmp/rclone_error.log && sleep 3; then
  # Notify success
  notify-send -a "Rclone Sync" -i dialog-information "Document Sync" "Sync completed successfully ✅"
  echo "Sync completed successfully"
else
  # Capture error message
  ERROR_MSG=$(</tmp/rclone_error.log)
  notify-send -a "Rclone Sync" -u critical -i dialog-error "Document Sync Failed" "$ERROR_MSG"
  echo "Document Sync Failed"
fi
