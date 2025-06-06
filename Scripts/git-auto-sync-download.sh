#!/usr/bin/env zsh

SCRIPT_NAME="git-auto-sync2.sh"
SCRIPT_FOLDER="./"

cd "$SCRIPT_FOLDER"
wget "https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/$SCRIPT_NAME"
# curl -O "https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/$SCRIPT_NAME"

chmod +x "$SCRIPT_NAME"