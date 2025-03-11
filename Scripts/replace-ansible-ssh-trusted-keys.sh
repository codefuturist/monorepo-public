#!/usr/bin/env bash

#
# Usage examples:
#   1) Provide both arguments explicitly:
#        ./update_ansible_ssh.sh append  "ssh-rsa AAAAB3NzaC1yc2E..."
#      or
#        ./update_ansible_ssh.sh replace "ssh-rsa AAAAB3NzaC1yc2E..."
#
#   2) Provide no arguments, and you'll be prompted:
#        ./update_ansible_ssh.sh
#
#   3) Provide only one argument (for example, "append"), and you'll be prompted for the missing one:
#        ./update_ansible_ssh.sh append
#

ANSIBLE_USER="ansible"
ACTION="$1"    # "append" or "replace" (if provided)
NEW_KEY="$2"   # The SSH public key (if provided)

ANSIBLE_HOME_DIR="/home/${ANSIBLE_USER}"
SSH_DIR="${ANSIBLE_HOME_DIR}/.ssh"
AUTH_KEYS_FILE="${SSH_DIR}/authorized_keys"

# Check if ansible user exists
if ! id "${ANSIBLE_USER}" &>/dev/null; then
  echo "User '${ANSIBLE_USER}' does not exist. Exiting."
  exit 1
fi

# 1) Prompt for ACTION if not provided
if [ -z "${ACTION}" ]; then
  read -rp "Do you want to 'append' or 'replace'? " ACTION
fi

# Validate ACTION
if [[ "${ACTION}" != "append" && "${ACTION}" != "replace" ]]; then
  echo "Invalid action. Use 'append' or 'replace'. Exiting."
  exit 1
fi

# 2) Prompt for NEW_KEY if not provided
if [ -z "${NEW_KEY}" ]; then
  read -rp "Enter the public SSH key: " NEW_KEY
fi

# Verify NEW_KEY is not empty after prompt
if [ -z "${NEW_KEY}" ]; then
  echo "No SSH key provided. Exiting."
  exit 1
fi

# 3) Ensure the .ssh directory exists with the correct permissions
if [ ! -d "${SSH_DIR}" ]; then
  # mkdir -p "${SSH_DIR}"
  chown "${ANSIBLE_USER}:${ANSIBLE_USER}" "${SSH_DIR}"
  chmod 700 "${SSH_DIR}"
  echo "Created directory: ${SSH_DIR}"
fi

# 4) Perform the chosen action on authorized_keys
case "${ACTION}" in
  replace)
    echo "Replacing the authorized_keys with the specified key..."
    echo "${NEW_KEY}" > "${AUTH_KEYS_FILE}"
    ;;
  append)
    echo "Appending the specified key to the authorized_keys..."
    echo "${NEW_KEY}" >> "${AUTH_KEYS_FILE}"
    ;;
esac

# 5) Set the correct ownership and permissions
chown "${ANSIBLE_USER}:${ANSIBLE_USER}" "${AUTH_KEYS_FILE}"
chmod 600 "${AUTH_KEYS_FILE}"

echo "Successfully updated SSH key for user '${ANSIBLE_USER}' using '${ACTION}' mode."
