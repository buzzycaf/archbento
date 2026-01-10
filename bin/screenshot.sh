#!/usr/bin/env bash
set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
NAME="shot-$(date +%F_%H-%M-%S).png"
FILE="$DIR/$NAME"

mkdir -p "$DIR"

# Select area; exit cleanly if cancelled
GEOM="$(slurp)" || exit 0

# Capture to a temp file first (so "No" can mean "clipboard only")
TMP="$(mktemp --suffix=.png)"
cleanup() { rm -f "$TMP"; }
trap cleanup EXIT

grim -g "$GEOM" "$TMP"

# Copy to clipboard immediately
wl-copy < "$TMP"
notify-send "Screenshot" "Copied to clipboard"

# Ask whether to save to default path (no file chooser = no portal headache)
if zenity --question --title="Screenshot" --text="Save screenshot to:\n$FILE" --ok-label="Save" --cancel-label="Don't Save"; then
  mv -f "$TMP" "$FILE"
  trap - EXIT
  notify-send "Screenshot saved" "$FILE"
fi
