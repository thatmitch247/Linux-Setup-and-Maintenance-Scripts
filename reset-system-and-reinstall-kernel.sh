#!/bin/bash
set -e

# Function to confirm user wants to proceed
confirm_action() {
  read -p "This script will reset configuration files, reinstall kernel, and set up secure APT and Snap sources. Proceed? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Action aborted by the user."
    exit 1
  fi
}

# Step 1: Resetting APT sources to secure HTTPS
reset_apt_sources() {
  echo "Resetting APT sources to use secure HTTPS..."
  sudo sed -i 's|http://|https://|g' /etc/apt/sources.list
  sudo apt update
}

# Step 2: Setting up secure keyservers for GPG
setup_secure_keyservers() {
  echo "Setting secure keyservers..."
  echo "keyserver hkps://keys.openpgp.org" | sudo tee -a /etc/apt/trusted.gpg.d/default-keyserver.conf
}

# Step 3: Reinstalling core APT and Snap packages
reinstall_apt_snap() {
  echo "Reinstalling APT and Snap packages..."
  sudo apt install --reinstall apt apt-transport-https snapd
  sudo snap refresh
}

# Step 4: Download new GPG keys and verify
refresh_gpg_keys() {
  echo "Refreshing GPG keys..."
  sudo apt-key adv --keyserver hkps://keyserver.ubuntu.com --recv-keys <REPLACE_WITH_KEY_ID>
  sudo apt-key adv --keyserver hkps://keyserver.ubuntu.com --refresh-keys
}

# Step 5: Reinstalling the kernel
reinstall_kernel() {
  echo "Reinstalling the kernel..."
  KERNEL_VERSION=$(uname -r)
  sudo apt update
  sudo apt install --reinstall linux-image-$KERNEL_VERSION linux-headers-$KERNEL_VERSION
}

# Step 6: Cleaning up and resetting configurations
reset_configs() {
  echo "Resetting configurations..."
  sudo rm -rf /etc/apt/preferences.d/*
  sudo rm -rf /etc/apt/sources.list.d/*
  sudo apt update && sudo apt upgrade -y
}

# Step 7: Full system upgrade and cleanup
full_upgrade_cleanup() {
  echo "Performing full system upgrade and cleanup..."
  sudo apt dist-upgrade -y
  sudo apt autoremove --purge -y
  sudo apt clean
}

# Confirm and execute steps
confirm_action
reset_apt_sources
setup_secure_keyservers
reinstall_apt_snap
refresh_gpg_keys
reinstall_kernel
reset_configs
full_upgrade_cleanup

echo "System reset complete. A reboot is recommended."
