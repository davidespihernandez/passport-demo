#!/usr/bin/env bash
# Stream Deck launcher: opens a new iTerm window (see _open.sh).
"$(dirname "$0")/_open.sh" "docker logs -f --since 1m pp-proxy-local" 0
