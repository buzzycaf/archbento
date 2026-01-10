#!/usr/bin/env bash
set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
DEFAULT_NAME="shot-$(date +%F_%H-%M-%S).png"
DEFAULT_PATH="$DIR/$DEFAULT_NAME"

mkdir -p "$DIR"

# Save dialog (prefilled path + name)
FILE="$(zenity --file-selection \
  --save \
  --confirm-overwrite \
  --filename="$DEFAULT_PATH")" || exit 0

# Select area (exit cleanly if cancelled)
GEOM="$(slurp)" || exit 0

# Take screenshot
grim -g "$GEOM" "$FILE"

# Copy to clipboard
wl-copy < "$FILE"

# Notify user
notify-send "Screenshot" "Saved and copied to clipboard"
