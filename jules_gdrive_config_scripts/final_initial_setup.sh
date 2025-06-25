#!/bin/bash

echo "--- Starting Finalized Initial Setup Script --- "

# 1. Update package lists and install APT packages
echo "Updating package lists and installing APT dependencies (curl, unzip, ffmpeg, python3-pip, pipx)..."
sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y curl unzip ffmpeg python3-pip pipx
echo "APT dependencies installation/check finished."

# 2. Install rclone (binary download method if not found)
echo "Checking for rclone..."
if ! command -v rclone > /dev/null; then
  echo "rclone not found, installing rclone..."
  TEMP_RCLONE_INSTALL_DIR=$(mktemp -d -t rclone-install-XXXXXX)
  # Download rclone zip to the temporary directory
  if sudo curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip; then
    if sudo unzip -o rclone-current-linux-amd64.zip -d "$TEMP_RCLONE_INSTALL_DIR"; then
      RCLONE_EXEC_PATH=$(find "$TEMP_RCLONE_INSTALL_DIR" -name rclone -type f -print -quit)
      if [ -n "$RCLONE_EXEC_PATH" ] && [ -f "$RCLONE_EXEC_PATH" ]; then
        sudo cp "$RCLONE_EXEC_PATH" /usr/local/bin/ && \
        sudo chown root:root /usr/local/bin/rclone && \
        sudo chmod 755 /usr/local/bin/rclone && \
        echo "rclone installed successfully from $RCLONE_EXEC_PATH."
      else
        echo "Error: rclone executable not found after unzip in $TEMP_RCLONE_INSTALL_DIR."
      fi
    else
      echo "Error: Failed to unzip rclone-current-linux-amd64.zip."
    fi
    # Cleanup zip file if it was downloaded
    sudo rm -f rclone-current-linux-amd64.zip
  else
    echo "Error: Failed to download rclone-current-linux-amd64.zip."
  fi
  # Cleanup temporary install directory
  if [ -d "$TEMP_RCLONE_INSTALL_DIR" ]; then
    sudo rm -rf "$TEMP_RCLONE_INSTALL_DIR"
  fi
  echo "Cleaned up rclone installation files."
else
  echo "rclone is already installed. Path: $(command -v rclone)"
fi

# 3. Install yt-dlp using pipx
echo "Installing/Upgrading yt-dlp using pipx..."
if command -v pipx > /dev/null; then
    pipx install yt-dlp
    pipx ensurepath
    echo "yt-dlp installation/upgrade via pipx completed."
else
    echo "Error: pipx command not found. Cannot install yt-dlp. (Ensure pipx was installed in step 1)"
fi

# 4. Download and extract service account key (if it doesn't exist in the working directory /app/)
JSON_KEY_FILENAME="red-splice-408603-f464c7873a2c.json"
# IMPORTANT: Replace the URL below with your actual, persistent download link for the ZIP file containing the JSON key.
# The FileMail link is temporary and will expire.
ZIP_DOWNLOAD_URL="https://1009.filemail.com/api/file/get?filekey=vkIbksXhh2bxidsUwJzvPvubvswup9k68C6egcoitZ5oUXE9J-x0Xw&pk_vid=defd88abe5ba6a47175057997002cf2f"
TEMP_ZIP_NAME="my_gdrive_key.zip"

echo "Checking for service account key: $(pwd)/$JSON_KEY_FILENAME..."
if [ ! -f "$JSON_KEY_FILENAME" ]; then # Check in current dir, which should be /app/
    echo "Service account JSON key '$JSON_KEY_FILENAME' not found. Downloading and extracting..."
    if command -v curl > /dev/null && command -v unzip > /dev/null; then
        curl -L "$ZIP_DOWNLOAD_URL" -o "$TEMP_ZIP_NAME"
        if [ $? -eq 0 ] && [ -f "$TEMP_ZIP_NAME" ]; then
            unzip -o "$TEMP_ZIP_NAME" "$JSON_KEY_FILENAME" -d . # Extract to current directory /app/
            if [ $? -eq 0 ] && [ -f "$JSON_KEY_FILENAME" ]; then
                echo "Service account JSON key downloaded and extracted as $(pwd)/$JSON_KEY_FILENAME."
            else
                echo "Error: Failed to extract $JSON_KEY_FILENAME from $TEMP_ZIP_NAME. Check ZIP content and filename, or ZIP might be empty/corrupt."
            fi
            rm "$TEMP_ZIP_NAME"
        else
            echo "Error: Failed to download $TEMP_ZIP_NAME from $ZIP_DOWNLOAD_URL. Curl exit code: $?"
        fi
    else
        echo "Error: curl or unzip command not found. Cannot download/extract service account key."
    fi
else
    echo "Service account JSON key '$JSON_KEY_FILENAME' already exists in $(pwd)/."
fi

# 5. Create rclone configuration file
KEY_FILE_ABS_PATH="$(pwd)/$JSON_KEY_FILENAME"
RCLONE_CONFIG_DIR="$HOME/.config/rclone"
RCLONE_CONFIG_FILE="$RCLONE_CONFIG_DIR/rclone.conf"

echo "Ensuring rclone config directory: $RCLONE_CONFIG_DIR..."
mkdir -p "$RCLONE_CONFIG_DIR"

if [ -f "$KEY_FILE_ABS_PATH" ]; then
    echo "Creating/Overwriting rclone config: $RCLONE_CONFIG_FILE..."
    cat << EOF > "$RCLONE_CONFIG_FILE"
[gdrive_service_upload]
type = drive
scope = drive
service_account_file = ${KEY_FILE_ABS_PATH}
root_folder_id = 1kH_5zhb_891KQcFjPz3cMowLHJO8rHPG
EOF
    echo "rclone.conf created/updated successfully, using key: ${KEY_FILE_ABS_PATH}"
else
    echo "Error: JSON key file '$KEY_FILE_ABS_PATH' not found. Cannot create rclone.conf. Please check download/extraction in step 4."
fi

# 6. Ensure google_drive_manager.sh (expected from repo) is executable
SCRIPT_NAME="google_drive_manager.sh"
echo "Checking for $SCRIPT_NAME in $(pwd) and ensuring it is executable..."
if [ -f "$SCRIPT_NAME" ]; then
    chmod +x "$SCRIPT_NAME"
    echo "$SCRIPT_NAME found and ensured executable."
else
    echo "Warning: $SCRIPT_NAME not found in the root of the repository. It should be provided by the user in their repo and will be cloned."
fi

# 7. Final Verification of Tool Versions and rclone setup
echo "--- Verifying Tool Versions & Setup --- "
echo "ffmpeg version (first line):"
if command -v ffmpeg > /dev/null; then ffmpeg -version 2>&1 | head -n 1; else echo "ffmpeg: Not Found"; fi
echo "yt-dlp version:"
if command -v yt-dlp > /dev/null; then yt-dlp --version; elif [ -f "$HOME/.local/bin/yt-dlp" ]; then $HOME/.local/bin/yt-dlp --version; else echo "yt-dlp: Not Found"; fi
echo "rclone version (first line):"
if command -v rclone > /dev/null; then rclone version | head -n 1; else echo "rclone: Not Found"; fi
echo "Verifying rclone access to Google Drive (listing first 5 files, if config exists)..."
if [ -f "$RCLONE_CONFIG_FILE" ] && [ -f "$KEY_FILE_ABS_PATH" ]; then
    rclone lsf gdrive_service_upload: --config="$RCLONE_CONFIG_FILE" --files-only | head -n 5
else
    echo "Skipping rclone lsf verification: rclone.conf or key file might be missing, or JSON key download failed."
fi

echo "--- Finalized Initial Setup Script Finished --- "
