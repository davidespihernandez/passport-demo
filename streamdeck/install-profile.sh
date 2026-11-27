#!/usr/bin/env bash
# Installs the "Demo" iTerm profile (big font, fixed window size) used by the Stream Deck launchers.
# Edit streamdeck/iterm-demo-profile.json first if you want another font size or window size.
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$DEST"
cp "$D/iterm-demo-profile.json" "$DEST/passport-demo.json"
echo "Installed profile 'Demo' in $DEST"
