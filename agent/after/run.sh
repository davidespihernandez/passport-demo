#!/usr/bin/env bash
# Starts Claude Code as the agent: no Postman key, only the Passport key of the agent user,
# which can request access but never approve it. The key comes from .env and is never printed.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY="$(grep '^PASSPORT_API_KEY_AGENT=' "$HERE/../../.env" | cut -d= -f2- | tr -d "\"'\r")"
[ -n "$KEY" ] || { echo "PASSPORT_API_KEY_AGENT is empty in .env"; exit 1; }
cd "$HERE"
PASSPORT_API_KEY_AGENT="$KEY" exec claude
