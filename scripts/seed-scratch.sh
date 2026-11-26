#!/usr/bin/env bash
# Makes sure the disposable "Scratch API" collection exists in the demo workspace (target of the DELETE in chapter 7).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
K="$(env_get POSTMAN_API_KEY_SA)"; [ -n "$K" ] || { echo "POSTMAN_API_KEY_SA missing in .env"; exit 1; }
H=(-H "x-api-key: $K")
URL="https://api.getpostman.com/collections?workspace=$WORKSPACE_ID"
if curl -s "${H[@]}" "$URL" | jq -e '.collections[]? | select(.name=="Scratch API")' >/dev/null; then
  echo "Scratch API: already there."
else
  curl -s -X POST "${H[@]}" -H 'Content-Type: application/json' "$URL" \
    -d '{"collection":{"info":{"name":"Scratch API","schema":"https://schema.getpostman.com/json/collection/v2.1.0/collection.json","description":"Disposable collection for the Passport demo (DELETE target)."},"item":[]}}' \
    | jq -e '.collection.id' >/dev/null && echo "Scratch API: created." || { echo "Scratch API: could not create it."; exit 1; }
fi
