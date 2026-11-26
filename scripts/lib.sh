# Shared settings for the demo scripts. Source it, do not run it.
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$REPO/.env"
PP_DIR="${PP_DIR:-$HOME/passport-local}"          # keys live outside the repo
NS_ID="${NS_ID:-5a99bfaa-d6af-4805-ac6c-9b1b228e1aa9}"   # namespace David-Espi-Demo
WORKSPACE_ID="b43984d2-2319-4792-9095-634778044fbe"      # Postman workspace "Passport demo"
VAULT_NAME=pp-vault-dev
PROXY_NAME=pp-proxy-local
NET=pp-net
VAULT_TOKEN_LOCAL=root-token-for-local-dev
PROXY_IMAGE=ociregistry.usepassport.ai/passport/passport-proxy:latest

env_get() { grep "^$1=" "$ENV_FILE" | head -1 | cut -d= -f2- | tr -d "\"'\r"; }
# The CLI (default ~/.passport) is the Member, the agent identity. The admin API calls use the admin session kept in ADMIN_DIR.
ADMIN_DIR="${ADMIN_DIR:-$HOME/passport-admin}"
api() { PASSPORT_DIR="$ADMIN_DIR" node "$PP_DIR/passport-api.js" "$@"; }
ok()   { printf '  \033[32mOK\033[0m   %s\n' "$*"; }
fail() { printf '  \033[31mFAIL\033[0m %s\n' "$*"; FAILED=1; }
