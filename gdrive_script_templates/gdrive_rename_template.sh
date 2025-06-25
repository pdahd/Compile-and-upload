#!/bin/bash
# Google Drive Rename (Move) Template Script for Jules
#
# This script renames a file or folder on the configured Google Drive remote.
# It uses 'rclone moveto', which effectively renames if source and destination are in the same parent.
# It should be adapted by Jules into 'google_drive_manager.sh' for actual execution.
#
# Instructions for Jules:
# 1. Replace 'old_remote_path_here' with the current full path/filename on Google Drive (e.g., "reports/old_name.txt" or "my_folder_to_rename").
# 2. Replace 'new_remote_path_here' with the desired new full path/filename on Google Drive (e.g., "reports/new_name.txt" or "my_renamed_folder").
#    Ensure the new name is properly quoted if it contains spaces.

OLD_REMOTE_PATH="old_remote_path_here"
NEW_REMOTE_PATH="new_remote_path_here" # Example: "My New Document Name.pdf" or "archive/2025_report.docx"

RCLONE_REMOTE_NAME="gdrive_service_upload"
RCLONE_CONFIG_PATH="$HOME/.config/rclone/rclone.conf" # Standard path from Initial Setup

echo "gdrive_manager (rename template): Preparing to rename '$OLD_REMOTE_PATH' to '$NEW_REMOTE_PATH' on Google Drive..."

echo "Executing rename (moveto) from '${RCLONE_REMOTE_NAME}:${OLD_REMOTE_PATH}' to '${RCLONE_REMOTE_NAME}:${NEW_REMOTE_PATH}'..."
# If NEW_REMOTE_PATH contains spaces, rclone typically handles it if the whole argument is quoted.
rclone moveto "${RCLONE_REMOTE_NAME}:${OLD_REMOTE_PATH}" "${RCLONE_REMOTE_NAME}:${NEW_REMOTE_PATH}" --config="$RCLONE_CONFIG_PATH" -vv

RC_RENAME_EXIT_CODE=$?
if [ $RC_RENAME_EXIT_CODE -eq 0 ]; then
  echo "Successfully renamed '$OLD_REMOTE_PATH' to '$NEW_REMOTE_PATH' on Google Drive."
  echo "Verifying new path presence and old path absence..."
  sleep 8

  # Verify new path
  echo "Checking for new path: '${NEW_REMOTE_PATH}'..."
  # Use lsf for files, lsd for directories. For a general rename, checking if old path is gone and new one exists is key.
  # We'll try to list the new path. If it's a file, lsf. If a dir, lsf on it should also work.
  rclone lsf "${RCLONE_REMOTE_NAME}:${NEW_REMOTE_PATH}" --config="$RCLONE_CONFIG_PATH" --max-depth 1 --files-only # Try as file first
  RC_LSF_NEW_FILE_EXIT_CODE=$?
  rclone lsd "${RCLONE_REMOTE_NAME}:" --config="$RCLONE_CONFIG_PATH" | grep --color=always "$(basename "$NEW_REMOTE_PATH")/" # Try as dir
  RC_LSD_NEW_DIR_EXIT_CODE=$?

  if [ $RC_LSF_NEW_FILE_EXIT_CODE -eq 0 ] || [ $RC_LSD_NEW_DIR_EXIT_CODE -eq 0 ]; then
    echo "Verification Success: New path '$NEW_REMOTE_PATH' found on Google Drive."
  else
    echo "Verification Warning: New path '$NEW_REMOTE_PATH' NOT found after rename attempt. Listing new file exit: $RC_LSF_NEW_FILE_EXIT_CODE, Listing new dir exit: $RC_LSD_NEW_DIR_EXIT_CODE."
  fi

  # Verify old path is gone
  echo "Checking for old path: '${OLD_REMOTE_PATH}'..."
  rclone lsf "${RCLONE_REMOTE_NAME}:${OLD_REMOTE_PATH}" --config="$RCLONE_CONFIG_PATH" --max-depth 1 --files-only > /dev/null 2>&1
  RC_LSF_OLD_EXIT_CODE=$?

  if [ $RC_LSF_OLD_EXIT_CODE -ne 0 ]; then # Should fail if old path is truly gone
    echo "Verification Success: Old path '$OLD_REMOTE_PATH' no longer found (as expected)."
  else
    echo "Verification Warning: Old path '$OLD_REMOTE_PATH' STILL found after rename attempt. This is unexpected."
  fi
else
  echo "Error renaming from '$OLD_REMOTE_PATH' to '$NEW_REMOTE_PATH'. Rclone exit code: $RC_RENAME_EXIT_CODE"
fi

echo "gdrive_manager (rename template): Task finished."
exit $RC_RENAME_EXIT_CODE
