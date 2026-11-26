#!/usr/bin/env bash
# Keeps both Passport sessions (agent in ~/.passport, admin in ADMIN_DIR) alive by renewing them every 5 min.
# Started by start.sh in the background. Stop it: kill "$(cat /tmp/pp-keepalive.pid)"
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
PIDF=/tmp/pp-keepalive.pid
[ -f "$PIDF" ] && kill "$(cat "$PIDF")" 2>/dev/null
echo $$ > "$PIDF"
while true; do renew_sessions; sleep 300; done
