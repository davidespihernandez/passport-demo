# passport-demo

Demo for a webinar on **Postman Passport**: let an AI agent call an authenticated API
(the Postman API) without ever holding the API key.

> Status: work in progress. Nothing here has been validated end to end yet.

## Story

1. **Before**: Claude uses a Postman API key from its config. It can list workspaces, and it can also print the key.
2. **Setup**: an admin registers the Postman API in a Passport namespace and binds the key (stored in a vault) to the endpoints.
3. **After**: same agent, same tools, config uses `{{vault:POSTMAN_API_KEY}}`. The agent has no key to show.
4. **Access**: the agent requests read-only access, a human approves it in Passport.
5. **Call**: listing workspaces works. The trace shows the call.
6. **Deny**: a destructive call is refused by Passport even though the key would allow it.
7. **Revoke**: the grant is revoked and the next call fails. The key is never rotated.

## Layout

| Path | Purpose |
|---|---|
| `postman/` | Folder linked to the Postman workspace "Passport demo" (Native Git) |
| `passport/` | Passport namespace, endpoints and bindings as code |
| `agent/before`, `agent/after` | Agent config with the key in clear vs. a Passport reference |
| `scripts/` | `preflight` (is everything up?) and `reset` (back to the initial state) |
| `docs/` | Runbook, timings, fallback plan |

## Rules

- Secrets only in `.env` (gitignored). `.env.example` holds placeholders.
- Proxy keys (CA, reference) and `~/.passport/` never go in this repo.
- This repo is public. Treat every commit as published.

## Open questions

- Does a Postman service account key work directly, or only to obtain a short-lived token (which would reach the agent)?
- How fast does a revocation take effect?
- What error does the agent see when Passport denies a call?
- `NO_PROXY` excludes `.postman.com` and `.getpostman.com` by default; it must be cleared for the demo.
