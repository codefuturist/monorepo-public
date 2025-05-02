#!/usr/bin/env zsh

# -----------------------------------------------------------------------------
# upgrade-apps.zsh
#
# Syncs the catalog and upgrades apps, with these modes:
#   • Read apps from a file (one per line)
#   • Take apps as CLI arguments
#   • Append an app to your list file (--add)
#
# Defaults:
#   • List file: ./apps.txt
#
# Usage:
#   # Upgrade based on a file
#   ./upgrade-apps.zsh apps.txt
#
#   # Upgrade based on CLI args
#   ./upgrade-apps.zsh sftpgo photoprism syncthing
#
#   # Append an app to your default list (apps.txt)
#   ./upgrade-apps.zsh --add metube
#
#   # Append to a specific file
#   ./upgrade-apps.zsh --add minio custom-list.txt
# -----------------------------------------------------------------------------

set -euo pipefail

# Default list file
DEFAULT_LIST="apps.txt"

# Parse options
zparseopts -A opts -a=add -h=help

# Show usage
usage() {
  cat <<EOF
Usage:
  $0 [--add <app>] [<apps-file>]
  $0 [<app1> [app2 ...]]

Modes:
  --add, -a <app>      Append <app> to your list file (default: $DEFAULT_LIST)
                       If you provide a second arg, it’s taken as the file.
  <apps-file>          Read apps (one per line) from this file.
  <app1> [app2 ...]    Upgrade these apps directly.

Examples:
  # Upgrade from apps.txt
  $0 apps.txt

  # Upgrade specific apps
  $0 sftpgo photoprism

  # Add “metube” to apps.txt
  $0 --add metube

  # Add “minio” to custom-list.txt
  $0 --add minio custom-list.txt
EOF
  exit 1
}

# If help requested
[[ -n ${opts[help]:-} ]] && usage

# Handle --add mode
if [[ -n ${opts[add]:-} ]]; then
  APP_TO_ADD=${opts[add][1]}
  TARGET_FILE=${(@)argv[1]:-$DEFAULT_LIST}

  # Ensure file exists (or create it)
  touch "$TARGET_FILE"
  chmod u+rw "$TARGET_FILE"

  # Check for duplicates
  if grep -Fxq "$APP_TO_ADD" "$TARGET_FILE"; then
    echo "→ '$APP_TO_ADD' is already in '$TARGET_FILE'"
  else
    echo "$APP_TO_ADD" >> "$TARGET_FILE"
    echo "→ Added '$APP_TO_ADD' to '$TARGET_FILE'"
  fi

  exit 0
fi

# Otherwise, determine apps to upgrade
APPS=()

# If first arg is a readable file and it’s the only arg or there are no flags
if [[ $# -eq 1 && -r $1 ]]; then
  LIST_FILE=$1
  while IFS= read -r app || [[ -n $app ]]; do
    [[ -z ${app// } || ${app#\#} != $app ]] && continue  # skip blank/comment
    APPS+="$app"
  done < "$LIST_FILE"
else
  # Treat all args as app names
  if (( $# )); then
    for arg in "$@"; do
      APPS+="$arg"
    done
  else
    echo "Error: No apps specified."
    usage
  fi
fi

# Confirm we have something to do
(( ${#APPS[@]} )) || { echo "Error: No apps to upgrade."; exit 2; }

# Function to run a CLI command with status
run_cli() {
  echo -n "→ $1 … "
  if cli -c "$1"; then
    echo "OK"
  else
    echo "FAIL"
    return 1
  fi
}

echo "Starting upgrade process ($(date))"
echo

# Sync catalog
run_cli "app catalog sync"
echo

# Upgrade each app
echo "Upgrading ${#APPS[@]} app(s): ${APPS[*]}"
for app in "${APPS[@]}"; do
  run_cli "app upgrade $app" || {
    echo "⚠ Warning: Upgrade of '$app' failed; continuing."
  }
done

echo
echo "Done! ($(date))"
