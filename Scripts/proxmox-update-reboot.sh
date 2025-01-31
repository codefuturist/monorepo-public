#!/usr/bin/env bash
#
# auto_update_reboot.sh
# Updates Ubuntu packages and reboots if needed, without any user interaction.

# Prevent any apt prompts
export DEBIAN_FRONTEND=noninteractive

# Update package lists
apt update -y

# Perform distribution upgrade
apt dist-upgrade -y

reboot
