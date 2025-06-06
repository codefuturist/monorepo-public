#!/usr/bin/env zsh

# Script metadata
SCRIPT_VERSION="1.2.0"
SCRIPT_DESCRIPTION="Git Auto-Sync Script Installer"

# Default configuration (can be overridden by command line arguments)
DEFAULT_SCRIPT_NAME="git-auto-sync2.sh"
DEFAULT_SCRIPT_FOLDER="/usr/local/bin"
DEFAULT_SCRIPT_USER="$USER"
DEFAULT_REPO_URL="https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts"

# Initialize variables
SCRIPT_NAME="$DEFAULT_SCRIPT_NAME"
SCRIPT_FOLDER="$DEFAULT_SCRIPT_FOLDER"
SCRIPT_USER="$DEFAULT_SCRIPT_USER"
REPO_URL="$DEFAULT_REPO_URL"
INTERACTIVE=true
FORCE=false
DRY_RUN=false
VERBOSE=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Usage function
usage() {
    cat << EOF
${BOLD}$SCRIPT_DESCRIPTION v$SCRIPT_VERSION${NC}

${BOLD}USAGE:${NC}
    $0 [OPTIONS]

${BOLD}OPTIONS:${NC}
    -s, --script-name NAME     Script name to download (default: $DEFAULT_SCRIPT_NAME)
    -d, --directory DIR        Installation directory (default: $DEFAULT_SCRIPT_FOLDER)
    -u, --user USER           Owner for the script (default: current user)
    -r, --repo-url URL        Repository base URL (default: GitHub repo)
    -f, --force               Force installation without prompts
    -n, --dry-run             Show what would be done without executing
    -v, --verbose             Enable verbose output
    -q, --quiet               Disable interactive mode
    -h, --help                Show this help message

${BOLD}EXAMPLES:${NC}
    $0                                    # Interactive installation
    $0 -s my-script.sh -d ~/bin -u colin # Install to custom location
    $0 --dry-run                          # Preview installation
    $0 --force --quiet                    # Silent installation

${BOLD}NOTES:${NC}
    • Root privileges required for system directories (/usr/local/bin)
    • Existing scripts are automatically backed up
    • Use --dry-run to preview changes before installation
EOF
}

# Logging functions
log() {
    echo -e "${GREEN}✓ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

error() {
    echo -e "${RED}✗ ERROR: $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}" >&2
}

verbose() {
    [[ "$VERBOSE" == true ]] && echo -e "${BLUE}[VERBOSE] $1${NC}"
}

# Interactive prompt function
prompt() {
    local message="$1"
    local default="$2"
    local response
    
    if [[ "$INTERACTIVE" == false ]]; then
        echo "$default"
        return
    fi
    
    echo -ne "${YELLOW}$message${NC}"
    [[ -n "$default" ]] && echo -ne " ${BLUE}[default: $default]${NC}"
    echo -n ": "
    read response
    echo "${response:-$default}"
}

# Confirmation prompt
confirm() {
    local message="$1"
    local default="${2:-n}"
    
    if [[ "$FORCE" == true ]]; then
        return 0
    fi
    
    local response
    echo -ne "${YELLOW}$message${NC} "
    [[ "$default" == "y" ]] && echo -ne "(Y/n)" || echo -ne "(y/N)"
    echo -n ": "
    read response
    
    response="${response:-$default}"
    [[ "$response" =~ ^[Yy]([Ee][Ss])?$ ]]
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--script-name)
                SCRIPT_NAME="$2"
                shift 2
                ;;
            -d|--directory)
                SCRIPT_FOLDER="$2"
                shift 2
                ;;
            -u|--user)
                SCRIPT_USER="$2"
                shift 2
                ;;
            -r|--repo-url)
                REPO_URL="$2"
                shift 2
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -q|--quiet)
                INTERACTIVE=false
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Interactive configuration
interactive_config() {
    if [[ "$INTERACTIVE" == false ]]; then
        return
    fi
    
    echo -e "${BOLD}=== Git Auto-Sync Script Installer ===${NC}\n"
    
    SCRIPT_NAME=$(prompt "Script name to download" "$SCRIPT_NAME")
    SCRIPT_FOLDER=$(prompt "Installation directory" "$SCRIPT_FOLDER")
    SCRIPT_USER=$(prompt "Script owner" "$SCRIPT_USER")
    
    echo -e "\n${BOLD}Installation Summary:${NC}"
    echo "  Script: $SCRIPT_NAME"
    echo "  Location: $SCRIPT_FOLDER"
    echo "  Owner: $SCRIPT_USER"
    echo "  Source: $REPO_URL/$SCRIPT_NAME"
    
    if ! confirm "Proceed with installation?" "y"; then
        info "Installation cancelled by user"
        exit 0
    fi
    echo
}

# Validation functions
validate_config() {
    local errors=0
    
    if [[ -z "$SCRIPT_NAME" ]]; then
        error "Script name cannot be empty"
        ((errors++))
    fi
    
    if [[ -z "$SCRIPT_FOLDER" ]]; then
        error "Installation directory cannot be empty"
        ((errors++))
    fi
    
    if [[ -z "$SCRIPT_USER" ]]; then
        error "Script owner cannot be empty"
        ((errors++))
    fi
    
    return $errors
}

# Pre-flight checks
preflight_checks() {
    verbose "Running pre-flight checks..."
    
    # Check if we need root privileges
    if [[ "$SCRIPT_FOLDER" == /usr/* ]] || [[ "$SCRIPT_FOLDER" == /opt/* ]]; then
        if [[ $EUID -ne 0 ]]; then
            error "Root privileges required for system directory: $SCRIPT_FOLDER"
            info "Try running with sudo: sudo $0"
            exit 1
        fi
    fi
    
    # Check if target directory exists
    if [[ ! -d "$SCRIPT_FOLDER" ]]; then
        warning "Target directory '$SCRIPT_FOLDER' does not exist"
        if confirm "Create directory?" "y"; then
            if [[ "$DRY_RUN" == false ]]; then
                mkdir -p "$SCRIPT_FOLDER" || {
                    error "Failed to create directory '$SCRIPT_FOLDER'"
                    exit 1
                }
                log "Created directory: $SCRIPT_FOLDER"
            else
                info "[DRY RUN] Would create directory: $SCRIPT_FOLDER"
            fi
        else
            exit 1
        fi
    fi
    
    # Check directory permissions
    if [[ ! -w "$SCRIPT_FOLDER" ]]; then
        error "Cannot write to directory '$SCRIPT_FOLDER'"
        exit 1
    fi
    
    # Check if user exists
    if ! id "$SCRIPT_USER" &>/dev/null; then
        error "User '$SCRIPT_USER' does not exist"
        exit 1
    fi
    
    # Check download tools
    if ! command -v wget &>/dev/null && ! command -v curl &>/dev/null; then
        error "Neither wget nor curl is available"
        info "Please install wget or curl to continue"
        exit 1
    fi
    
    verbose "Pre-flight checks completed successfully"
}

# Main installation function
install_script() {
    local script_path="$SCRIPT_FOLDER/$SCRIPT_NAME"
    local script_url="$REPO_URL/$SCRIPT_NAME"
    local backup_suffix=".backup.$(date +%Y%m%d_%H%M%S)"
    
    # Create backup if script already exists
    if [[ -f "$script_path" ]]; then
        info "Existing script found, creating backup..."
        if [[ "$DRY_RUN" == false ]]; then
            cp "$script_path" "${script_path}${backup_suffix}"
            log "Backup created: ${script_path}${backup_suffix}"
        else
            info "[DRY RUN] Would create backup: ${script_path}${backup_suffix}"
        fi
    fi
    
    # Download script
    info "Downloading script from: $script_url"
    if [[ "$DRY_RUN" == false ]]; then
        if command -v wget &>/dev/null; then
            wget -q --show-progress -O "$script_path" "$script_url" || {
                error "Failed to download script with wget"
                exit 1
            }
        else
            curl -fsSL "$script_url" -o "$script_path" || {
                error "Failed to download script with curl"
                exit 1
            }
        fi
        
        # Verify download
        if [[ ! -f "$script_path" ]] || [[ ! -s "$script_path" ]]; then
            error "Download failed or file is empty"
            exit 1
        fi
        
        # Set ownership and permissions
        chown "$SCRIPT_USER:$SCRIPT_USER" "$script_path"
        chmod 755 "$script_path"
        
        log "Script successfully installed: $script_path"
        info "Owner: $(stat -c '%U:%G' "$script_path")"
        info "Permissions: $(stat -c '%a' "$script_path")"
        
        # Show usage hint
        echo -e "\n${BOLD}Next steps:${NC}"
        echo "  • Run the script: $script_path --help"
        echo "  • View the script: cat $script_path"
        if [[ -f "${script_path}${backup_suffix}" ]]; then
            echo "  • Restore backup if needed: mv ${script_path}${backup_suffix} $script_path"
        fi
    else
        info "[DRY RUN] Would download: $script_url"
        info "[DRY RUN] Would install to: $script_path"
        info "[DRY RUN] Would set owner: $SCRIPT_USER"
        info "[DRY RUN] Would set permissions: 755"
    fi
}

# Main execution
main() {
    parse_args "$@"
    
    if [[ "$DRY_RUN" == true ]]; then
        info "DRY RUN mode enabled - no changes will be made"
    fi
    
    validate_config || exit 1
    interactive_config
    preflight_checks
    install_script
    
    if [[ "$DRY_RUN" == false ]]; then
        log "Installation completed successfully!"
    else
        info "DRY RUN completed - no changes were made"
    fi
}

# Run main function
main "$@"