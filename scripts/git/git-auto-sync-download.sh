#!/usr/bin/env zsh

SCRIPT_URL="${SCRIPT_URL:-https://raw.githubusercontent.com/codefuturist/monorepo-public/main/scripts/git/git-auto-sync.sh}"
SCRIPT_NAME="${SCRIPT_NAME:-git-auto-sync.sh}"
DEST_DIR="${DEST_DIR:-/usr/local/bin}"
DEST_PATH="$DEST_DIR/$SCRIPT_NAME"
# USER="${SCRIPT_USER:-$USER}"
USER="${SCRIPT_USER:-colin}"

curl -fsSL "$SCRIPT_URL" -o "/tmp/$SCRIPT_NAME" || { echo "Download failed"; exit 1; }

# wget -q -O "$TMP_FILE" "$SCRIPT_URL" || { echo "Download failed"; exit 1; }

if [ "/tmp/$SCRIPT_NAME" != "$DEST_PATH" ]; then
  rm -f "$DEST_PATH"
  install -o "$USER" -g "$USER" -m 777 "/tmp/$SCRIPT_NAME" "$DEST_PATH"
else
  echo "Source and destination are the same, skipping install."
fi

# 0 * * * * /usr/local/bin/git-auto-sync-download.sh >> /var/log/git-auto-sync-download.log 2>&1
