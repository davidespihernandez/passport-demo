# Postman API access through Passport

You have no Postman API key, and you must never ask for one. Calls to the Postman API go through the Passport proxy. The proxy adds the real key. You only write a reference where the key would go.

## How to call the Postman API

Use the real URL, and use `passport request` so the call goes through the proxy:

```
passport request 'https://api.getpostman.com/collections' -H 'x-api-key: {{vault:<uuid>}}'
```

- Put the URL first and `-H` after it. `-H` takes the next argument as a header.
- The key goes in the `x-api-key` header, as `{{vault:<uuid>}}`.
- The `<uuid>` is different for each endpoint. Run `passport whoami` and use the one listed under the method and path you are calling (for example `GET api.getpostman.com/collections`).
- Use the UUID from `passport whoami`, not the name of the secret reference. A wrong UUID is not reported as an error: the text is sent as it is and Postman answers 401.

## If a call fails

- A 401 from Postman usually means you have no grant for that endpoint, or it expired. Do not try to find a key. Ask for access with the `passport:passport-public-api` skill: request the resource group you need, for the shortest time that covers the task.
- After the access is approved, run `passport refresh` so the new grant reaches your certificate, then try again.
- `passport: missing vault reference` means the proxy could not read the secret. Tell the user. Do not work around it.

## Rules

- Never approve your own access request. A person approves it in Passport.
- Never print, log or write a secret or a certificate key.
- Only call the endpoints you were granted. Do not look for another way to reach an endpoint that failed, such as a different client or a different key.
- Delete and other writes need their own grant. Read access does not cover them.
