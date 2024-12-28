#!/bin/bash
set -e

# URL for the files to be downloaded
BASE_URL="https://cdimage.ubuntu.com/daily-live/20240421/"
FILES=("noble-desktop-amd64.manifest" "noble-desktop-amd64.list" "SHA256SUMS" "SHA256SUMS.gpg")
TMP_DIR="/tmp/ubuntu_check"

# Step 1: Create a temporary directory for downloads
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# Function to confirm user wants to proceed
confirm_action() {
  read -p "This script will download and verify the Ubuntu 24.04 system integrity files. Proceed? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Action aborted by the user."
    exit 1
  fi
}

# Step 2: Download necessary files
download_files() {
  echo "Downloading files from $BASE_URL..."
  
  for file in "${FILES[@]}"; do
    echo "Downloading $file..."
    wget -q "${BASE_URL}${file}" -O "$file"
    if [[ ! -f "$file" ]]; then
      echo "Failed to download $file. Exiting."
      exit 1
    fi
  done
  echo "All files downloaded successfully."
}

# Step 3: Verify SHA256SUMS file with GPG signature
verify_gpg_signature() {
  echo "Verifying SHA256SUMS with GPG..."
  
  # Import the Ubuntu archive keyring for verification
  sudo apt install -y ubuntu-keyring
  gpg --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg --verify SHA256SUMS.gpg SHA256SUMS
}

# Step 4: Verify integrity of downloaded files with SHA256SUMS
verify_sha256_checksums() {
  echo "Verifying file integrity with SHA256SUMS..."
  
  sha256sum -c SHA256SUMS --ignore-missing
}

# Step 5: Verify current system files against the manifest and list
verify_system_files() {
  echo "Verifying system files against the manifest and file list..."
  
  while IFS=' ' read -r file checksum; do
    # Skip if file does not exist on system
    if [[ ! -f "$file" ]]; then
      echo "[MISSING] $file is missing from the system."
      continue
    fi

    # Calculate checksum of the local file and compare with manifest checksum
    local_checksum=$(sha256sum "$file" | awk '{print $1}')
    if [[ "$local_checksum" == "$checksum" ]]; then
      echo "[MATCH] $file matches the expected checksum."
    else
      echo "[TAMPERED] $file has been modified."
    fi
  done < noble-desktop-amd64.manifest
}

# Confirm and execute steps
confirm_action
download_files
verify_gpg_signature
verify_sha256_checksums
verify_system_files

echo "System verification completed. Check above for any discrepancies."
