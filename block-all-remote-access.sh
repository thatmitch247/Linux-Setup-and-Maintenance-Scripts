#!/bin/bash
set -e

# Function to confirm user wants to proceed
confirm_action() {
  read -p "This script will block remote access, reset network settings, set up secure DNS, and enforce HTTPS only. Proceed? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Action aborted by the user."
    exit 1
  fi
}

# Step 1: Resetting Network Interfaces
reset_network_interfaces() {
  echo "Resetting network interfaces and settings..."
  # Restart network manager to reset settings
  sudo systemctl restart NetworkManager.service
  
  # Bring down all interfaces except the loopback and bring them back up
  for iface in $(ls /sys/class/net | grep -v lo); do
    sudo ip link set $iface down
    sudo ip addr flush dev $iface
    sudo ip link set $iface up
  done
}

# Step 2: Set up secure DNS with Cloudflare
setup_secure_dns() {
  echo "Configuring DNS to use Cloudflare..."
  sudo bash -c 'echo -e "nameserver 1.1.1.1\nnameserver 1.0.0.1" > /etc/resolv.conf'
  sudo chattr +i /etc/resolv.conf  # Prevent changes to resolv.conf
}

# Step 3: Block all remote access
block_remote_access() {
  echo "Blocking all remote access..."
  sudo ufw reset
  sudo ufw default deny incoming
  sudo ufw default deny outgoing
  sudo ufw deny 22/tcp  # Block SSH
  sudo ufw deny 3389/tcp  # Block RDP
}

# Step 4: Allow HTTPS-only outgoing traffic on a single port
allow_https_only() {
  local port=443  # Specify HTTPS port

  echo "Allowing HTTPS-only traffic on port $port..."
  # Allow outgoing traffic on the specified HTTPS port
  sudo ufw allow out $port/tcp

  # Deny all other ports except for DNS (port 53) and the specified port
  sudo ufw allow out 53/udp  # Allow DNS requests
  sudo ufw deny out to any port 80  # Block HTTP traffic
  sudo ufw deny out to any port 20:79  # Block FTP, Telnet, etc.
  sudo ufw deny out to any port 81:442  # Block all non-HTTPS ports below 443
  sudo ufw deny out to any port 444:65535  # Block all ports above 443
}

# Step 5: Enforce Firewall Rules
enforce_firewall() {
  echo "Enforcing firewall rules..."
  sudo ufw enable
}

# Confirm and execute steps
confirm_action
reset_network_interfaces
setup_secure_dns
block_remote_access
allow_https_only
enforce_firewall

echo "Network restrictions applied. All traffic is now HTTPS-only on port 443 with Cloudflare DNS. Reboot recommended."
