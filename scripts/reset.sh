#!/usr/bin/env bash
# Returns the demo to the clean state: revokes every active grant in the namespace
# and gets a new certificate with no endpoints. Does not touch the vault or the proxy.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
ME="$(passport auth status 2>&1 | awk '$1=="subject"{print $2}')"
[ -n "$ME" ] || { echo "Not logged in. Run: passport login"; exit 1; }
N=0
for G in $(api GET "/api/v2/access-grants?namespaceId=$NS_ID" | jq -r --arg u "$ME" '.body.data[]? | select(.status=="active" and .userId==$u) | .id'); do
  api DELETE /api/v2/access-grants/$G >/dev/null && N=$((N+1))
done
echo "Revoked $N active grant(s) of $ME."
passport refresh >/dev/null 2>&1
"$(dirname "${BASH_SOURCE[0]}")/preflight.sh"
