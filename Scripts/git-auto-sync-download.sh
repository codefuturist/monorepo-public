#!/usr/bin/env zsh

SCRIPT_NAME="git-auto-sync2.sh"
SCRIPT_FOLDER="./"
SCRIPT_USER="colin"

cd "$SCRIPT_FOLDER"
wget "https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/$SCRIPT_NAME"
# curl -O "https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/$SCRIPT_NAME"

chown $SCRIPT_USER:$SCRIPT_USER "$SCRIPT_NAME"
chmod +x "$SCRIPT_NAME"