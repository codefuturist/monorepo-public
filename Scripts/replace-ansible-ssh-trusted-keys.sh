#!/usr/bin/env bash
#
# Usage:
#   ./update_ansible_ssh.sh append  "ssh-rsa AAAAB3NzaC1yc2E..."
#   ./update_ansible_ssh.sh replace "ssh-rsa AAAAB3NzaC1yc2E..."
#
# This script updates the ansible user's authorized_keys file by either
# appending or replacing it with the specified SSH public key.

ANSIBLE_USER="ansible"
ACTION="$1"    # "append" or "replace"
NEW_KEY="$2"
ANSIBLE_HOME_DIR="/home/${ANSIBLE_USER}"
SSH_DIR="${ANSIBLE_HOME_DIR}/.ssh"
AUTH_KEYS_FILE="${SSH_DIR}/authorized_keys"

# Verify arguments
if [[ -z "${ACTION}" || -z "${NEW_KEY}" ]]; then
  echo "Usage: $0 [append|replace] \"<public ssh key>\""
  exit 1
fi

# Ensure ansible user exists
if ! id "${ANSIBLE_USER}" &>/dev/null; then
  echo "User '${ANSIBLE_USER}' does not exist."
  exit 1
fi

# Create the .ssh directory if it doesn't exist
if [ ! -d "${SSH_DIR}" ]; then
  mkdir -p "${SSH_DIR}"
  chown "${ANSIBLE_USER}:${ANSIBLE_USER}" "${SSH_DIR}"
  chmod 700 "${SSH_DIR}"
  echo "Created directory: ${SSH_DIR}"
fi

case "${ACTION}" in

  replace)
    echo "Replacing the authorized_keys with the specified key..."
    echo "${NEW_KEY}" > "${AUTH_KEYS_FILE}"
    ;;

  append)
    echo "Appending the specified key to the authorized_keys..."
    echo "${NEW_KEY}" >> "${AUTH_KEYS_FILE}"
    ;;

  *)
    echo "Invalid action. Use 'append' or 'replace'."
    exit 1
    ;;
esac

# Set correct ownership and permissions
chown "${ANSIBLE_USER}:${ANSIBLE_USER}" "${AUTH_KEYS_FILE}"
chmod 600 "${AUTH_KEYS_FILE}"

echo "Successfully updated SSH key for user '${ANSIBLE_USER}' using '${ACTION}' mode."
