#!/usr/bin/env bash
# Builds the Stream Deck launchers as tiny .app bundles in streamdeck/apps/ (not committed).
# Each app runs _open.sh, which opens a NEW iTerm window; no terminal is involved in launching it.
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"; mkdir -p "$D/apps"
mk(){ # name, command, keep-shell
  rm -rf "$D/apps/$1.app"
  osacompile -o "$D/apps/$1.app" -e "do shell script quoted form of \"$D/_open.sh\" & \" \" & quoted form of \"$2\" & \" $3\""
}
mk 1-start "scripts/start.sh" 1
mk 2-reset "scripts/reset.sh" 1
mk 3-trace "docker logs -f --since 1m pp-proxy-local" 0
mk 4-agent-before "agent/before/run.sh" 0
mk 7-agent-after "agent/after/run.sh" 0
mk 10-refresh "scripts/refresh.sh" 1
echo "Built in $D/apps"
