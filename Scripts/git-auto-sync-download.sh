#!/usr/bin/env zsh

SCRIPT_NAME="git-auto-sync2.sh"
SCRIPT_FOLDER="/usr/local/bin"
SCRIPT_USER="colin"

cd "$SCRIPT_FOLDER"
curl -fsSL "https://raw.githubusercontent.com/codefuturist/monorepo-public/main/Scripts/$SCRIPT_NAME" -o "$SCRIPT_NAME"
install -o "$SCRIPT_USER" -g "$SCRIPT_USER" -m 777 "$SCRIPT_NAME" "$SCRIPT_FOLDER"
