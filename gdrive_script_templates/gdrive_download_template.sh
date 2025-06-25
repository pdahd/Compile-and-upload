#!/bin/bash
# Google Drive Download Template Script for Jules
#
# This script downloads a file from the configured Google Drive remote to the local working directory.
# It should be adapted by Jules into 'google_drive_manager.sh' for actual execution.
#
# Instructions for Jules:
# 1. Replace 'remote_file_to_download_here' with the actual path/filename on Google Drive (e.g., "important_document.pdf" or "my_folder/data.zip").
# 2. Replace 'local_filename_here' with the desired local filename (e.g., "./downloaded_doc.pdf").

REMOTE_FILE_TO_DOWNLOAD="remote_file_to_download_here"
LOCAL_SAVE_AS_FILENAME="local_filename_here" # Will be saved in /app/

RCLONE_REMOTE_NAME="gdrive_service_upload"
RCLONE_CONFIG_PATH="$HOME/.config/rclone/rclone.conf" # Standard path from Initial Setup

echo "gdrive_manager (download template): Preparing to download '$REMOTE_FILE_TO_DOWNLOAD' from Google Drive to './$LOCAL_SAVE_AS_FILENAME'..."

echo "Downloading '${RCLONE_REMOTE_NAME}:${REMOTE_FILE_TO_DOWNLOAD}' to './$LOCAL_SAVE_AS_FILENAME'..."
rclone copyto "${RCLONE_REMOTE_NAME}:${REMOTE_FILE_TO_DOWNLOAD}" "./${LOCAL_SAVE_AS_FILENAME}" --config="$RCLONE_CONFIG_PATH" -vv

RC_DOWNLOAD_EXIT_CODE=$?
if [ $RC_DOWNLOAD_EXIT_CODE -eq 0 ]; then
  echo "File '$REMOTE_FILE_TO_DOWNLOAD' successfully downloaded as './$LOCAL_SAVE_AS_FILENAME'."
  echo "Verifying downloaded file presence and size locally..."
  ls -lh "./${LOCAL_SAVE_AS_FILENAME}"
else
  echo "Error downloading file '$REMOTE_FILE_TO_DOWNLOAD'. Rclone exit code: $RC_DOWNLOAD_EXIT_CODE"
fi

echo "gdrive_manager (download template): Task finished."
exit $RC_DOWNLOAD_EXIT_CODE
