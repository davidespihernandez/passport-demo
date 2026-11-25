#!/usr/bin/env bash
# Checks the demo is ready to start. Read-only.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
FAILED=0
echo "Preflight"
docker info >/dev/null 2>&1 && ok "Docker running" || fail "Docker not running"
for c in $VAULT_NAME $PROXY_NAME; do
  [ "$(docker inspect -f '{{.State.Running}}' $c 2>/dev/null)" = true ] && ok "$c running" || fail "$c not running (run scripts/start.sh)"
done
[ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8081/readyz)" = 200 ] && ok "proxy ready" || fail "proxy not ready"
docker exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=$VAULT_TOKEN_LOCAL $VAULT_NAME \
  vault kv get -field=value secret/postman-api-key >/dev/null 2>&1 && ok "Postman key is in the vault" || fail "Postman key missing in the vault (run scripts/start.sh)"
passport auth status >/dev/null 2>&1 && ok "Passport CLI logged in" || fail "Passport CLI not logged in (passport login)"
N=$(passport whoami 2>&1 | grep -cE '^\s+(GET|DELETE|POST|PUT)')
[ "$N" = 0 ] && ok "no grants in the certificate (clean start)" || fail "certificate still has $N endpoint(s): run scripts/reset.sh"
if [ -z "${NO_PROXY_CHECK:-}" ]; then case "${NO_PROXY:-}${no_proxy:-}" in *postman*) fail "NO_PROXY excludes postman domains";; *) ok "NO_PROXY does not exclude Postman";; esac; fi
echo; [ "$FAILED" = 0 ] && echo "Ready." || { echo "Not ready."; exit 1; }
