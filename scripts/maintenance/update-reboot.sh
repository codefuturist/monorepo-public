#!/usr/bin/env bash
#
# auto_update_reboot.sh
# Updates Ubuntu packages and reboots if needed, without any user interaction.

# Prevent any apt prompts
export DEBIAN_FRONTEND=noninteractive

# Update package lists
apt-get update -y

# Perform distribution upgrade
apt-get dist-upgrade -y

# Clean up unused packages
apt-get autoremove -y
apt-get autoclean -y

# Check if system requires a reboot
if [ -f /var/run/reboot-required ]; then
    echo "Reboot required. Rebooting now..."
    /sbin/reboot
else
    echo "No reboot required."
fi
