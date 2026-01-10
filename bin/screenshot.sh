#!/usr/bin/env bash
#!/usr/bin/env bash
set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
NAME="shot-$(date +%F_%H-%M-%S).png"
FILE="$DIR/$NAME"

mkdir -p "$DIR"

# Select area; exit cleanly if cancelled
GEOM="$(slurp)" || exit 0

# Save screenshot
grim -g "$GEOM" "$FILE"

# Copy to clipboard
wl-copy < "$FILE"

# Notify with saved path
notify-send "Screenshot saved" "$FILE"

