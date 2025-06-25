#!/bin/bash
# Google Drive List Files/Folders Template Script for Jules
#
# This script lists files and/or folders in a specified path on the configured Google Drive remote.
# It should be adapted by Jules into 'google_drive_manager.sh' for actual execution.
#
# Instructions for Jules:
# 1. Replace 'remote_path_to_list_here' with the actual path on Google Drive you want to list.
#    - To list the root of your configured remote (inside root_folder_id): "" or "."
#    - To list a subdirectory: "your_subdirectory_name"
#    - To list a subdirectory recursively: "your_subdirectory_name" (and rclone command might need --recursive or similar, or use `rclone tree`)
# 2. Adjust rclone command flags as needed (e.g., --files-only, --dirs-only, --max-depth N, lsjson, lsl, etc.)

REMOTE_PATH_TO_LIST="remote_path_to_list_here" # Default to empty for root, or specify a subfolder e.g., "zzz"

RCLONE_REMOTE_NAME="gdrive_service_upload"
RCLONE_CONFIG_PATH="$HOME/.config/rclone/rclone.conf" # Standard path from Initial Setup

echo "gdrive_manager (list template): Preparing to list contents of '${RCLONE_REMOTE_NAME}:${REMOTE_PATH_TO_LIST}' on Google Drive..."

# Example: List files and folders at the specified path, non-recursive (max-depth 1)
# Use 'lsf' for a simple file list, 'lsd' for directories, 'ls' for combined, 'tree' for recursive tree view.
# For this template, we'll use 'rclone ls' which shows size and name.
echo "Listing contents of '${RCLONE_REMOTE_NAME}:${REMOTE_PATH_TO_LIST}' (max-depth 1)..."
rclone ls "${RCLONE_REMOTE_NAME}:${REMOTE_PATH_TO_LIST}" --config="$RCLONE_CONFIG_PATH" --max-depth 1 -vv

RC_LIST_EXIT_CODE=$?
if [ $RC_LIST_EXIT_CODE -eq 0 ]; then
  echo "Listing action completed successfully."
else
  echo "Error during listing operation. Rclone exit code: $RC_LIST_EXIT_CODE"
fi

echo "gdrive_manager (list template): Task finished."
exit $RC_LIST_EXIT_CODE
