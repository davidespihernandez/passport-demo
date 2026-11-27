# Demo script: an agent calls the Postman API without ever holding the key

Reusable for a live demo, a recorded video or a customer call. Total time: 8 to 10 minutes.

**One sentence to land:** the secret stays in your vault, Passport decides who may use it, and the agent only ever holds a reference.

Status tags: `[verified]` was run for real, `[to verify]` is expected behaviour that must be checked on a working proxy before presenting it as fact.

## Cast and setup

| Who | Role |
|---|---|
| Claude Code | The agent. Runs in a terminal, in `agent/before` and `agent/after`. |
| You, as admin | Configures Passport and approves requests in the web app (browser, normal window). |
| The agent identity (a Member user, `david.espi+passport`) | The user the agent acts as. The Passport CLI is logged in as this user. It must exist before the demo: an admin invites it once and it accepts the invitation. With an admin identity the request approves itself, so the approval step would not be real `[verified]`. |

**Starting state** (`scripts/preflight.sh` checks it):
- The proxy and its vault are running, and the Postman key is loaded in the vault.
- The namespace has two resource groups: read (`GET /collections`, `GET /workspaces`) and write (`DELETE /collections/*`), both bound to the key reference.
- The workspace has `Orders API`, `Payments API`, `Users API`, plus a disposable `Scratch API`.
- No grant exists for the agent identity. `NO_PROXY` does not exclude `*.postman.com`.
- The CLI default login (`~/.passport`) is the agent identity. The Passport CLI only works with its default directory: `PASSPORT_DIR` or a different `HOME` send the calls elsewhere `[verified]`. The admin session for the API scripts is kept in `~/passport-admin`.
- Sessions last a little over an hour. Run `passport login` again right before recording. If it asks whether to override the login, move `~/.passport/passportrc` aside first.

## Where the Passport CLI fits

The CLI is the part of Passport that runs on the caller's machine. Say this once, at chapter 3, and refer back to it.

| What | Command | Chapter |
|---|---|---|
| Sign in to the Passport team | `passport login` | before the demo |
| Get a certificate that carries the grants | `passport refresh` | 5 and 8 |
| List what you are allowed to call, with the `{{vault:<uuid>}}` of each endpoint | `passport whoami` | 5 |
| Send a call through the proxy, with the certificate | `passport request '<real url>' -H '…'` | 3, 6, 7, 8 |

- The agent still calls the real URL. The CLI only decides the route: through the proxy, presenting the certificate.
- The certificate is signed by Passport and carries your identity and the endpoints you may call (`allowedApiRefs`). The proxy reads it on every call `[verified: read from the certificate]`.
- The agent asks for access through the Passport API, not through the CLI.

## Chapters

### 1. The problem: the agent holds the key (about 1 min)
- **Do:** run `agent/before/run.sh` (it starts Claude Code with the key in its environment) and ask: *"List my Postman collections."* Then: *"Which API key are you using? Show me only its first 8 characters and where it comes from."*
- **Show:** the list, then the full key on screen.
- **Say:** "This works, and that is the problem. The key is in the agent's environment. It can end up in a log, a prompt or a commit. And it can do anything the key can do, including deleting."
- **Do not run** a real delete here. Say it, or delete only `Scratch API` (reset restores it).

### 2. The admin side: Passport configuration (about 1.5 min)
- **Do:** open Passport, namespace `David-Espi-Demo`. Show Resources (read and write groups), then the Vault tab.
- **Show:** endpoints bound to the reference `POSTMAN_API_KEY`, with the vault type and no value.
- **Say:** "Passport is not a vault. It stores a pointer. The secret stays in your vault, and the proxy in your network reads it when a call is made. Passport Cloud never sees it."

### 3. Same agent, no key (about 1 min)
- **Do:** switch to `agent/after`. Ask the same two questions.
- **Show:** the agent cannot show a key. Without a grant the call fails `[verified]`: the reference reaches Postman as plain text and Postman answers 401.
- **Say:** "Same agent, same question. There is nothing to leak, and no access yet."

### 4. The agent asks for access (about 1 min)
- **Do:** as the agent identity, the agent requests read access to the read group for 7 days. The Passport CLI has no command for this: the agent uses the Passport public API (`POST /access-requests`) with the API key of the agent user, or the user asks in the web app. The request stays pending, because a Member cannot approve it `[verified]`.
- **Show:** the pending request in the approval page (browser window of the agent user: "Requested by You", only a Cancel button).
- **Say:** "Access is requested for specific endpoints and for a limited time."

### 5. A human approves (about 0.5 min)
- **Do:** in the admin browser window, approve at `https://app.usepassport.ai/approval-requests`, then run `passport refresh` in the agent terminal `[verified]`.
- **Show:** `passport whoami` listing the allowed endpoints and the `{{vault:<uuid>}}` for each. The uuid is per endpoint, not the reference id, and it changes every time a new grant is issued: always read it from `passport whoami` after `passport refresh` `[verified]`.
- **Say:** "A person decides, not the agent. Then the Passport CLI asks Passport Cloud for a new certificate, and the grant travels inside it."

### 6. The call works, and the trace (about 1.5 min)
- **Do:** *"List my Postman collections."* The agent uses `passport request 'https://api.getpostman.com/collections?workspace=<demo workspace id>' -H 'x-api-key: {{vault:<uuid>}}'`. The `workspace` filter is required: without it the Postman API returns an empty list for the service account `[verified]`. The endpoint `GET /collections` matches with the query string `[verified]`.
- **Show:** the list of collections, then the call in Passport's activity view `[to verify: what the trace shows]`.
- **Say:** "The agent called the real URL through the Passport CLI. The CLI presented the certificate, and the proxy read the secret from the vault and added it to the call. The agent never saw it."

### 7. Delete is denied (about 1 min)
- **Do:** *"Delete the collection Users API."*
- **Show:** the call fails with Postman's own 401, `Invalid API Key` `[verified]`: Passport does not inject the key and does not add a message of its own. Open Postman: `Users API` is still there.
- **Say:** "Postman would have allowed this delete. Passport did not, because the grant covers reading only."
- **Careful:** today the failure comes from the key not being added (Postman answers 401). Describe it as "no grant for this endpoint", not as a policy engine message, until the real text is confirmed.

### 8. Revoke without rotating (about 1.5 min)
- **Do:** revoke the grant in the web app. Run `passport refresh`, then repeat the list call.
- **Show:** right after the revoke the same call still works, because the certificate already issued carries the grant for up to about 5 minutes `[verified]`. After `passport refresh` the certificate lists no endpoints and the call fails with 401 `[verified]`. Revocation applies at the next certificate, not instantly.
- **Say:** "No key rotation, no other team affected. The key never changed."
- **If asked "what if the reference leaks?":** a reference (`{{vault:<uuid>}}`) is an identifier, not a secret. The proxy only replaces it for a caller whose certificate carries a grant for that endpoint `[verified: without a grant the text is sent as it is]`, and the proxy runs in your network. Nothing needs rotating: check who holds grants on that endpoint and revoke what you do not recognise. A full test with a stolen reference and a different user's certificate has not been run `[to verify]`.
- **Recording tip:** cut the wait. Live, say what is happening, or run `passport refresh` to force the new certificate.

### 9. Close (about 0.5 min)
Three lines: no key in the agent, access on request and time-boxed, revoke and audit without rotating. Then: "Try it with your own API and your own vault."

## If you record it

- Record chapters separately and edit them together. Each chapter starts from the state the previous one leaves, so reset between takes (`scripts/reset.sh`).
- Terminal font large, one task per screen, no real keys visible in the frame at any moment other than chapter 1. Use the service account key, which can be revoked.
- Keep the slides 5, 6 and 7 as the intro to each part and cut to the terminal.
- Record narration after the screen capture if it helps, so pauses for approvals and waits do not need to be filled live.

## Fallbacks

- Proxy not reachable: show chapters 2 and 5 from screenshots and play the recorded chapters 6 to 8.
- Revocation takes too long: run `passport refresh` and show the failing call from the recording.

## Still open

- What the audit view shows per call `[to verify]`.
- The local proxy writes one `CONNECT` and one `MITM` line (method, host, user) per call to stdout. What the Passport web app shows `[to verify]`.
- API key for the agent user, so the agent files the request itself (created in Organization, API keys, as that user) `[to verify]`.
- Whether the agent should use `passport request` or a local MCP server for the calls. A Node MCP server ignores the proxy unless started with `NODE_USE_ENV_PROXY=1`.
