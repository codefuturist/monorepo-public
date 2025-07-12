#!/usr/bin/env bash

set -euo pipefail

CONFIG_FILE="/etc/ssh/sshd_config"

# Ensure the script is run as root.
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo." >&2
    exit 1
fi

# Verify that the SSH configuration file exists.
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: SSH configuration file $CONFIG_FILE not found." >&2
    exit 1
fi

# Check if PasswordAuthentication is already enabled.
if grep -Eq '^\s*PasswordAuthentication\s+yes(\s|$)' "$CONFIG_FILE"; then
    echo "SSH password authentication is already enabled."
    exit 0
fi

# Create a backup of the SSH configuration file.
BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%F_%T)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

systemctl restart sshd

echo "Updated $CONFIG_FILE to enable SSH password authentication."
echo "SSH password authentication has been enabled."
