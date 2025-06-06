#!/usr/bin/env zsh

# Script configuration
SCRIPT_NAME="git-auto-sync2.sh"
SCRIPT_FOLDER="/usr/local/bin"
SCRIPT_USER="colin"
SCRIPT_URL="https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/$SCRIPT_NAME"
BACKUP_SUFFIX=".backup.$(date +%Y%m%d_%H%M%S)"

# Enable strict error handling
# set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}" >&2
}

# Check if running as root (required for /usr/local/bin)
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root to install to $SCRIPT_FOLDER"
    exit 1
fi

# Validate configuration
if [[ -z "$SCRIPT_NAME" || -z "$SCRIPT_FOLDER" || -z "$SCRIPT_USER" ]]; then
    error "Configuration variables cannot be empty"
    exit 1
fi

# Check if target directory exists and is writable
if [[ ! -d "$SCRIPT_FOLDER" ]]; then
    error "Target directory '$SCRIPT_FOLDER' does not exist"
    exit 1
fi

if [[ ! -w "$SCRIPT_FOLDER" ]]; then
    error "Cannot write to target directory '$SCRIPT_FOLDER'"
    exit 1
fi

# Check if user exists
if ! id "$SCRIPT_USER" &>/dev/null; then
    error "User '$SCRIPT_USER' does not exist"
    exit 1
fi

# Check if wget or curl is available
if command -v wget &>/dev/null; then
    DOWNLOAD_CMD="wget -q --show-progress"
elif command -v curl &>/dev/null; then
    DOWNLOAD_CMD="curl -fsSL"
else
    error "Neither wget nor curl is available"
    exit 1
fi

# Create backup if script already exists
SCRIPT_PATH="$SCRIPT_FOLDER/$SCRIPT_NAME"
if [[ -f "$SCRIPT_PATH" ]]; then
    log "Creating backup of existing script"
    cp "$SCRIPT_PATH" "${SCRIPT_PATH}${BACKUP_SUFFIX}"
fi

# Change to target directory
log "Changing to directory: $SCRIPT_FOLDER"
cd "$SCRIPT_FOLDER" || {
    error "Failed to change to directory '$SCRIPT_FOLDER'"
    exit 1
}

# Download the script
log "Downloading script from: $SCRIPT_URL"
if [[ "$DOWNLOAD_CMD" == "wget"* ]]; then
    $DOWNLOAD_CMD -O "$SCRIPT_NAME" "$SCRIPT_URL" || {
        error "Failed to download script with wget"
        exit 1
    }
else
    $DOWNLOAD_CMD "$SCRIPT_URL" -o "$SCRIPT_NAME" || {
        error "Failed to download script with curl"
        exit 1
    }
fi

# Verify download
if [[ ! -f "$SCRIPT_NAME" ]]; then
    error "Downloaded script file not found"
    exit 1
fi

if [[ ! -s "$SCRIPT_NAME" ]]; then
    error "Downloaded script file is empty"
    exit 1
fi

# Verify it's a shell script
if ! head -1 "$SCRIPT_NAME" | grep -q '^#!.*sh'; then
    warning "Downloaded file doesn't appear to be a shell script"
fi

# Set ownership (more secure than 777)
log "Setting ownership to $SCRIPT_USER:$SCRIPT_USER"
chown "$SCRIPT_USER:$SCRIPT_USER" "$SCRIPT_NAME" || {
    error "Failed to set ownership"
    exit 1
}

# Set secure permissions (executable but not world-writable)
log "Setting permissions to 755"
chmod 777 "$SCRIPT_NAME" || {
    error "Failed to set permissions"
    exit 1
}

# Verify final state
if [[ -x "$SCRIPT_PATH" ]]; then
    log "Script successfully installed: $SCRIPT_PATH"
    log "Owner: $(stat -c '%U:%G' "$SCRIPT_PATH")"
    log "Permissions: $(stat -c '%a' "$SCRIPT_PATH")"
    
    # Show script info
    if [[ -f "${SCRIPT_PATH}${BACKUP_SUFFIX}" ]]; then
        log "Backup created: ${SCRIPT_PATH}${BACKUP_SUFFIX}"
    fi
else
    error "Script installation verification failed"
    exit 1
fi

log "Installation completed successfully"