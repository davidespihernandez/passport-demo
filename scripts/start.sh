#!/usr/bin/env bash
# Starts the local Vault and Passport proxy, loads the Postman key into the vault,
# and points the Passport CLI at the proxy. Safe to run again at any time.
# The dev vault lives in memory: every run recreates it and seeds the key again.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

docker info >/dev/null 2>&1 || { echo "Docker is not running. Start Docker Desktop and run this again."; exit 1; }
[ -f "$PP_DIR/ref.pem" ] && [ -f "$PP_DIR/ca.pem" ] || { echo "Missing keys in $PP_DIR (ca.pem, ref.pem). They must be the ones registered in Passport; do not generate new ones."; exit 1; }
[ -f "$PP_DIR/passport-api.js" ] || { echo "Missing $PP_DIR/passport-api.js"; exit 1; }

KEY="$(env_get POSTMAN_API_KEY_SA)"; [ -n "$KEY" ] || { echo "POSTMAN_API_KEY_SA is empty in .env"; exit 1; }
renew_sessions
[ -f "$ADMIN_DIR/passportrc" ] || { echo "Missing admin session in $ADMIN_DIR (passportrc). See docs/runbook.md."; exit 1; }
ORG="$(passport auth status 2>&1 | awk '$1=="org"{print $2}')"; [ -n "$ORG" ] || { echo "Not logged in. Run: passport login"; exit 1; }

docker network inspect $NET >/dev/null 2>&1 || docker network create $NET >/dev/null

echo "Vault..."
docker rm -f $VAULT_NAME >/dev/null 2>&1 || true
docker run --cap-add=IPC_LOCK -d --name $VAULT_NAME --network $NET -p 8200:8200 \
  -e VAULT_DEV_ROOT_TOKEN_ID=$VAULT_TOKEN_LOCAL -e VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200 \
  hashicorp/vault:2.2.1 server -dev >/dev/null
for i in $(seq 1 20); do curl -s http://127.0.0.1:8200/v1/sys/health | grep -q '"sealed":false' && break; sleep 1; done
printf %s "$KEY" | docker exec -i -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=$VAULT_TOKEN_LOCAL \
  $VAULT_NAME vault kv put secret/postman-api-key value=- >/dev/null
unset KEY
echo "  key loaded in the vault (secret/postman-api-key)"

echo "Proxy..."
docker rm -f $PROXY_NAME >/dev/null 2>&1 || true
docker run -d --name $PROXY_NAME --network $NET -p 8443:8443 -p 8081:8081 -v "$PP_DIR":/tmp/pp-local \
  -e PASSPORT_PROXY_PRIVATE_KEY_PATH=/tmp/pp-local/ca.pem \
  -e PASSPORT_PROXY_REFERENCE_PRIVATE_KEY_PATH=/tmp/pp-local/ref.pem \
  -e PASSPORT_PROXY_JWKS_URL=https://api.usepassport.ai/api/v1/bundles/.well-known/jwks.json \
  -e PASSPORT_PROXY_ALLOWED_TEAM_IDS="$ORG" -e PASSPORT_PROXY_AUDIT_SINK=stdout \
  -e PASSPORT_PROXY_DATAPLANE_CERT_SANS=localhost -e PASSPORT_PROXY_VAULT_SOURCE=hashicorp \
  -e VAULT_ADDR=http://$VAULT_NAME:8200 -e VAULT_TOKEN=$VAULT_TOKEN_LOCAL \
  $PROXY_IMAGE >/dev/null
for i in $(seq 1 20); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8081/readyz)" = 200 ] && break; sleep 1; done

echo "CLI..."
passport setup --management-url http://localhost:8081 --proxy-url https://localhost:8443 >/dev/null 2>&1 || true
echo
"$(dirname "${BASH_SOURCE[0]}")/preflight.sh"

# keep both sessions alive during the demo
nohup "$(dirname "${BASH_SOURCE[0]}")/keepalive.sh" >/dev/null 2>&1 &
echo "Sessions: keepalive running (renews every 5 min)."
