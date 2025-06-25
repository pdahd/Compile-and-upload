#!/bin/bash
# Google Drive Upload Template Script for Jules
#
# This script uploads a local file to the configured Google Drive remote.
# It should be adapted by Jules into 'google_drive_manager.sh' for actual execution.
#
# Instructions for Jules:
# 1. Replace 'your_local_file_here' with the actual path to the local file to be uploaded (e.g., "./my_document.pdf").
# 2. Replace 'your_remote_filename_here' with the desired filename on Google Drive (e.g., "my_document_on_gdrive.pdf").
#    If you want to upload to a subdirectory, include it in the remote filename, e.g., "my_folder/my_document_on_gdrive.pdf".

LOCAL_FILE_TO_UPLOAD="your_local_file_here"
REMOTE_FILENAME_ON_DRIVE="your_remote_filename_here"

RCLONE_REMOTE_NAME="gdrive_service_upload"
RCLONE_CONFIG_PATH="$HOME/.config/rclone/rclone.conf" # Standard path from Initial Setup

echo "gdrive_manager (upload template): Preparing to upload '$LOCAL_FILE_TO_UPLOAD' to Google Drive as '$REMOTE_FILENAME_ON_DRIVE'..."

if [ ! -f "$LOCAL_FILE_TO_UPLOAD" ]; then
  echo "Error: Local file '$LOCAL_FILE_TO_UPLOAD' not found in current directory ($(pwd)) or specified path."
  exit 1
fi

echo "Uploading '$LOCAL_FILE_TO_UPLOAD' to '${RCLONE_REMOTE_NAME}:${REMOTE_FILENAME_ON_DRIVE}'..."
rclone copyto "$LOCAL_FILE_TO_UPLOAD" "${RCLONE_REMOTE_NAME}:${REMOTE_FILENAME_ON_DRIVE}" --config="$RCLONE_CONFIG_PATH" -vv

RC_UPLOAD_EXIT_CODE=$?
if [ $RC_UPLOAD_EXIT_CODE -eq 0 ]; then
  echo "File '$LOCAL_FILE_TO_UPLOAD' uploaded successfully as '$REMOTE_FILENAME_ON_DRIVE' to Google Drive."
  echo "Verifying uploaded file presence..."
  sleep 5
  # Extract directory and filename for verification if path contains subdirectories
  REMOTE_DIR_FOR_VERIFICATION=$(dirname "${REMOTE_FILENAME_ON_DRIVE}")
  REMOTE_FILE_FOR_VERIFICATION=$(basename "${REMOTE_FILENAME_ON_DRIVE}")
  if [ "$REMOTE_DIR_FOR_VERIFICATION" == "." ]; then # Uploaded to root of remote
      rclone lsf "${RCLONE_REMOTE_NAME}:" --config="$RCLONE_CONFIG_PATH" --files-only | grep --color=always "$REMOTE_FILE_FOR_VERIFICATION"
  else
      rclone lsf "${RCLONE_REMOTE_NAME}:${REMOTE_DIR_FOR_VERIFICATION}" --config="$RCLONE_CONFIG_PATH" --files-only | grep --color=always "$REMOTE_FILE_FOR_VERIFICATION"
  fi

  if [ $? -eq 0 ]; then
    echo "Verification successful: '$REMOTE_FILENAME_ON_DRIVE' found on Google Drive."
  else
    echo "Verification Warning: '$REMOTE_FILENAME_ON_DRIVE' NOT found on Google Drive after upload attempt (listing might be delayed or path issue)."
  fi
else
  echo "Error uploading file '$LOCAL_FILE_TO_UPLOAD'. Rclone exit code: $RC_UPLOAD_EXIT_CODE"
fi

echo "gdrive_manager (upload template): Task finished."
exit $RC_UPLOAD_EXIT_CODE
