#!/usr/bin/env bash
# Starts Claude Code with the Postman key in its environment: the "before" act.
# Run it from anywhere. The key comes from .env and is never printed.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY="$(grep '^POSTMAN_API_KEY_SA=' "$HERE/../../.env" | cut -d= -f2- | tr -d "\"'\r")"
[ -n "$KEY" ] || { echo "POSTMAN_API_KEY_SA is empty in .env"; exit 1; }
cd "$HERE"
POSTMAN_API_KEY="$KEY" exec claude
