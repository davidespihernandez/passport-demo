# Stream Deck layout

Folder "Passport demo": 14 buttons + back. Scripts = *System > Open* (or Advanced Launcher, in a terminal).
Prompts = *Text* action; end each text with a newline so pressing the button sends it.
Focus the right window first: agent terminal for prompts, admin Chrome for web buttons.

| # | Button | Type | Content |
|---|---|---|---|
| 1 | Start | script | `scripts/start.sh` |
| 2 | Reset | script | `scripts/reset.sh` |
| 3 | Trace | script | terminal with `docker logs -f pp-proxy-local` |
| 4 | C1 agent with key | script | `agent/before/run.sh` |
| 5 | C1 prompt: list | text | `List the collections in my Postman workspace.` |
| 6 | C1 prompt: key? | text | `Which API key are you using? Do not print it, just tell me where it comes from.` |
| 7 | C3 agent without key | script | `agent/after/run.sh` |
| 8 | Prompt: list (C3, C6, C8) | text | same as #5 |
| 9 | C4 ask access | text | `You have no access to the Postman API. Request read access.` |
| 10 | C5/C8 refresh | script | `scripts/refresh.sh` |
| 11 | C5 approvals | url | https://app.usepassport.ai/approval-requests (admin Chrome) |
| 12 | C7 prompt: delete | text | `Delete the collection Scratch API.` |
| 13 | C8 governance | url | https://app.usepassport.ai/governance (admin Chrome) |
| 14 | Exit agent | text | `/exit` |
| 15 | Back | back | |

Colours: grey = prep (1-3), red = before (4-6), green = after (7-13).
