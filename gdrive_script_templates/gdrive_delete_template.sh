#!/bin/bash
# Google Drive Delete Template Script for Jules
#
# This script deletes a file from the configured Google Drive remote.
# Based on previous observations, this is likely a PERMANENT DELETE, not move to trash.
# It should be adapted by Jules into 'google_drive_manager.sh' for actual execution.
#
# Instructions for Jules:
# 1. Replace 'remote_file_to_delete_here' with the actual path/filename on Google Drive to be deleted (e.g., "obsolete_report.docx" or "old_folder/temp_file.txt").

REMOTE_FILE_TO_DELETE="remote_file_to_delete_here"

RCLONE_REMOTE_NAME="gdrive_service_upload"
RCLONE_CONFIG_PATH="$HOME/.config/rclone/rclone.conf" # Standard path from Initial Setup

echo "gdrive_manager (delete template): Preparing to DELETE (presumed PERMANENTLY) '$REMOTE_FILE_TO_DELETE' from Google Drive..."
echo "IMPORTANT: Based on observed behavior with the service account, this operation is likely to be a PERMANENT DELETE and will NOT move the file to Google Drive's Trash."

# We will NOT use --drive-use-trash=false initially, to rely on rclone's default for GDrive (which we observed as permanent).
# If default ever changes to trash, this script would then move to trash.
# However, communication MUST state it's presumed permanent based on current observations.
echo "Attempting to delete '${RCLONE_REMOTE_NAME}:${REMOTE_FILE_TO_DELETE}' (observed behavior: permanent delete)..."
rclone delete "${RCLONE_REMOTE_NAME}:${REMOTE_FILE_TO_DELETE}" --config="$RCLONE_CONFIG_PATH" -vv

RC_DELETE_EXIT_CODE=$?
if [ $RC_DELETE_EXIT_CODE -eq 0 ]; then
  echo "File '$REMOTE_FILE_TO_DELETE' presumed PERMANENTLY DELETED from Google Drive (rclone delete command successful)."
  echo "Verifying file absence..."
  sleep 8 # Give GDrive time to update listing

  # Extract directory and filename for verification if path contains subdirectories
  REMOTE_DIR_FOR_VERIFICATION=$(dirname "${REMOTE_FILE_TO_DELETE}")
  REMOTE_FILE_FOR_VERIFICATION=$(basename "${REMOTE_FILE_TO_DELETE}")

  if [ "$REMOTE_DIR_FOR_VERIFICATION" == "." ]; then # File was in the root of remote
      rclone lsf "${RCLONE_REMOTE_NAME}:" --config="$RCLONE_CONFIG_PATH" --files-only | grep --color=always "$REMOTE_FILE_FOR_VERIFICATION"
  else
      rclone lsf "${RCLONE_REMOTE_NAME}:${REMOTE_DIR_FOR_VERIFICATION}" --config="$RCLONE_CONFIG_PATH" --files-only | grep --color=always "$REMOTE_FILE_FOR_VERIFICATION"
  fi

  if [ $? -ne 0 ]; then # grep returns non-zero if NOT found (which is what we want)
    echo "Verification Success: '$REMOTE_FILE_TO_DELETE' no longer found on Google Drive (consistent with deletion)."
  else
    echo "Verification Warning: '$REMOTE_FILE_TO_DELETE' STILL found after delete attempt. This is unexpected."
  fi
else
  echo "Error deleting file '$REMOTE_FILE_TO_DELETE'. Rclone exit code: $RC_DELETE_EXIT_CODE"
fi

echo "gdrive_manager (delete template): Task finished."
exit $RC_DELETE_EXIT_CODE
