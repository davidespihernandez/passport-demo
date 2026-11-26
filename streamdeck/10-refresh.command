#!/usr/bin/env bash
# Stream Deck launcher. Opens in the terminal associated with .command files (iTerm).
cd "$HOME/Documents/code/passport-demo" || exit 1
scripts/refresh.sh
echo; echo "[done]"; exec "$SHELL" -l
