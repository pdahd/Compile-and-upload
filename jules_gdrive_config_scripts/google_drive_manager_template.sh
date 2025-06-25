#!/bin/bash
# Google Drive Operations Manager Script for Jules
# This script's content will be dynamically updated by Jules (or the user via Jules)
# based on specific task instructions (e.g., to upload, download, list, delete,
# or rename files/folders on Google Drive using rclone).
#
# The rclone remote named 'gdrive_service_upload' and its configuration,
# including the service account key and root_folder_id, are expected to be
# set up by Jules' Initial Setup script (typically in $HOME/.config/rclone/rclone.conf).

# Default Action: List files and directories in the root of the configured Google Drive remote folder.
# This helps confirm rclone is working and can access the drive.

echo "google_drive_manager.sh: Executing default action (listing root of GDrive remote folder)..."

# Ensure rclone command and config file are accessible
if ! command -v rclone > /dev/null; then
    echo "Error: rclone command not found. Please ensure it was installed correctly in Initial Setup."
    exit 1
fi

RCLONE_CONFIG_PATH="$HOME/.config/rclone/rclone.conf" # Standard path

if [ ! -f "$RCLONE_CONFIG_PATH" ]; then
    echo "Error: rclone config file ($RCLONE_CONFIG_PATH) not found. Please ensure Initial Setup ran successfully and configured rclone."
    exit 1
fi

# List top-level files and directories in the configured Google Drive root folder
echo "Listing top-level files and directories in 'gdrive_service_upload:' (defined by root_folder_id in config)..."
rclone ls "gdrive_service_upload:" --config="$RCLONE_CONFIG_PATH" --max-depth 1 -vv

RC_EXIT_CODE=$?
if [ $RC_EXIT_CODE -eq 0 ]; then
  echo "google_drive_manager.sh: Default listing action completed successfully."
else
  echo "google_drive_manager.sh: Default listing action failed. Rclone exit code: $RC_EXIT_CODE"
fi

exit $RC_EXIT_CODE
