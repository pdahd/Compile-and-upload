#!/bin/bash
# Google Drive Mkdir (Create Directory) Template Script for Jules
#
# This script creates a new subdirectory in the configured Google Drive remote folder.
# It should be adapted by Jules into 'google_drive_manager.sh' for actual execution.
#
# Instructions for Jules:
# 1. Replace 'new_directory_name_here' with the desired name for the new subdirectory on Google Drive (e.g., "My New Project" or "archive/2025").

NEW_DIRECTORY_NAME="new_directory_name_here"

RCLONE_REMOTE_NAME="gdrive_service_upload"
RCLONE_CONFIG_PATH="$HOME/.config/rclone/rclone.conf" # Standard path from Initial Setup

echo "gdrive_manager (mkdir template): Preparing to create subdirectory '$NEW_DIRECTORY_NAME' on Google Drive..."

echo "Creating subdirectory '${RCLONE_REMOTE_NAME}:${NEW_DIRECTORY_NAME}'..."
rclone mkdir "${RCLONE_REMOTE_NAME}:${NEW_DIRECTORY_NAME}" --config="$RCLONE_CONFIG_PATH" -vv

RC_MKDIR_EXIT_CODE=$?
if [ $RC_MKDIR_EXIT_CODE -eq 0 ]; then
  echo "Subdirectory '$NEW_DIRECTORY_NAME' successfully created (or already existed) on Google Drive."
  echo "Verifying subdirectory presence..."
  sleep 8

  # Verify by trying to list the directory itself.
  # Adding a trailing slash to ensure rclone treats it as a directory.
  rclone lsf "${RCLONE_REMOTE_NAME}:${NEW_DIRECTORY_NAME}/" --config="$RCLONE_CONFIG_PATH" --max-depth 1 -vv
  RCLONE_LSF_EXIT_CODE=$?

  if [ $RCLONE_LSF_EXIT_CODE -eq 0 ]; then
    echo "Verification Success: Subdirectory '$NEW_DIRECTORY_NAME/' appears to exist on Google Drive."
  else
    echo "Verification Failed or Ambiguous: rclone lsf for '$NEW_DIRECTORY_NAME/' exited with code $RCLONE_LSF_EXIT_CODE. Manual check recommended if mkdir reported success."
  fi
else
  echo "Error creating subdirectory '$NEW_DIRECTORY_NAME'. Rclone exit code: $RC_MKDIR_EXIT_CODE"
fi

echo "gdrive_manager (mkdir template): Task finished."
exit $RC_MKDIR_EXIT_CODE
