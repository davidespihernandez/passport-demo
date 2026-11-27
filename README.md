# passport-demo

Demo for a webinar on **Postman Passport**: an AI agent (Claude Code) calls an authenticated API
(the Postman API) **without ever holding the API key**. A human approves access, and revoking it
needs no key rotation.

Full walkthrough with what to say and what to type: [`docs/demo-script.md`](docs/demo-script.md).

## Story (chapters)

1. **Before**: the agent has the Postman API key in its environment. It works, and it could print or misuse the key.
2. **Admin setup**: namespace, secret reference (key stays in a vault), resource groups (read / write), proxy.
3. **Same agent, no key**: it uses a `{{vault:<uuid>}}` placeholder; with no grant the call fails (401).
4. **Agent asks for access** as its own Passport identity (a Member), with its own API key.
5. **A human admin approves**; the agent runs `passport refresh` and gets a new certificate.
6. **The call works**; the proxy log is the trace.
7. **DELETE is denied** (read grant only).
8. **Revoke without rotating** the Postman key; the next certificate no longer has access.

## Requirements

- Docker (runs the Passport proxy and a dev HashiCorp Vault locally)
- `passport` CLI, `claude` (Claude Code), `jq`, `node`, `curl`, bash
- A Passport org with: one **Admin** and one **Member** user (the Member is the agent's identity), a namespace,
  a registry credential (Org Settings > Registry) to pull the proxy image
- A Postman API key (service account) and a workspace with a few collections plus a disposable `Scratch API`

## Quick start

```bash
cp .env.example .env          # fill it in (never commit .env)
scripts/start.sh              # Vault + proxy, seeds the key, runs preflight
scripts/reset.sh              # back to the clean state: no grants
agent/before/run.sh           # chapter 1: agent WITH the key
agent/after/run.sh            # chapters 3-8: agent WITHOUT the key, own Passport identity
```

`scripts/refresh.sh` = `passport refresh` + `passport whoami` (after an approval or a revocation).
The proxy log (the trace): `scripts/trace.sh` (readable view of `docker logs -f pp-proxy-local`).

Things that bit us (details in `docs/demo-script.md`):
- The CLI only works correctly with the default dir `~/.passport`; keep the **agent identity** logged in there, and the admin session in `~/passport-admin` (used by the scripts).
- The `{{vault:<uuid>}}` changes with every new grant: read it from `passport whoami` after `passport refresh`.
- `NO_PROXY` must not exclude `postman.com`, or calls bypass the proxy.
- The access token lasts ~15 min; `passport auth status` renews it from the refresh token. `scripts/start.sh` launches `scripts/keepalive.sh`, which renews both sessions (agent and admin) every 5 min, and `reset`/`refresh` renew them too.

## Stream Deck (optional)

Run the whole demo with buttons, no typing: build the launchers with `streamdeck/build-apps.sh`
(creates `streamdeck/apps/*.app`, not committed, they hold local paths) and follow the button table in
[`docs/streamdeck.md`](docs/streamdeck.md). Requires iTerm.

## Layout

| Path | Purpose |
|---|---|
| `scripts/` | `start` (bring everything up), `preflight` (is it ready?), `reset` (no grants, recreates `Scratch API` if missing), `seed-scratch`, `refresh`, `keepalive` (renews sessions), `lib.sh` (shared vars) |
| `agent/before`, `agent/after` | Agent folders: `CLAUDE.md` + `run.sh`. Before: key in env. After: no key, uses Passport and requests access through the Passport public API |
| `streamdeck/` | `_open.sh` (new iTerm window), `build-apps.sh` (launcher apps), `install-profile.sh` (iTerm "Demo" profile: font and size) |
| `docs/` | `demo-script.md` (script and verified facts), `streamdeck.md` (button layout) |
| `postman/` | Folder linked to the Postman workspace (Native Git) |

## Rules

- Secrets only in `.env` (gitignored). `.env.example` holds placeholders.
- Proxy keys (CA, reference), `~/.passport/` and the dev vault token files never go in this repo.
- This repo is public. Treat every commit as published.
- The Passport org used here is shared; rotating the registry key or changing the default proxy affects other people.

## Still open

- Whether Passport supports OAuth flows (docs only describe static secrets), and a per-call activity view in the web app.
- A deployment variant for agents running outside your laptop (CLI/daemon in the container, proxy reachable from there): not verified.
