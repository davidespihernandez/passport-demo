# Postman API access through Passport

You have no Postman API key, and you must never ask for one. Calls to the Postman API go through the Passport proxy. The proxy adds the real key. You only write a reference where the key would go.

## How to call the Postman API

Use the real URL, and use `passport request` so the call goes through the proxy:

```
passport request 'https://api.getpostman.com/collections?workspace=b43984d2-2319-4792-9095-634778044fbe' -H 'x-api-key: {{vault:<uuid>}}'
```

- Always add `?workspace=b43984d2-2319-4792-9095-634778044fbe` (the Passport demo workspace) when listing collections. Without it the API returns an empty list for this account.
- To delete a collection, use `DELETE https://api.getpostman.com/collections/<uid>`, where the uid comes from the list.

- Put the URL first and `-H` after it. `-H` takes the next argument as a header.
- The key goes in the `x-api-key` header, as `{{vault:<uuid>}}`.
- The `<uuid>` is different for each endpoint, and it changes every time you get a new grant. Run `passport refresh` and then `passport whoami` before you use it. Run `passport whoami` and use the one listed under the method and path you are calling (for example `GET api.getpostman.com/collections`).
- Use the UUID from `passport whoami`, not the name of the secret reference. A wrong UUID is not reported as an error: the text is sent as it is and Postman answers 401.

## How to ask for access

Request access only when the user explicitly asks you to. If you have no grant and the user has not asked for one, say that you have no access and wait.

You have a Passport API key for your own user in `$PASSPORT_API_KEY_AGENT`. It only lets you request access. Never print it.

```
curl -s -X POST https://api.usepassport.ai/public/v1/access-requests \
  -H "Authorization: Bearer $PASSPORT_API_KEY_AGENT" -H 'Content-Type: application/json' \
  -d '{"namespaceId":"5a99bfaa-d6af-4805-ac6c-9b1b228e1aa9","entities":[{"type":"resource_group","id":"184cf344-8511-4ce4-9c06-8b798a762b95"}],"durationDays":7,"message":"<why you need it>"}'
```

- `184cf344-...` is the read group (`Postman API - read`). Ask for read only, for the shortest time that covers the task.
- `durationDays` must be 7, 30 or 90. Use 7.
- The request stays pending until a person approves it. Tell the user and wait. Do not try to approve it.

## If a call fails

- A 401 from Postman usually means you have no grant for that endpoint, or it expired. Do not try to find a key. Tell the user you have no access to that endpoint and stop. Do not request access yourself.
- After the access is approved, run `passport refresh` so the new grant reaches your certificate, then try again.
- `passport: missing vault reference` means the proxy could not read the secret. Tell the user. Do not work around it.

## Rules

- Never approve your own access request. A person approves it in Passport.
- Never print, log or write a secret or a certificate key.
- Only call the endpoints you were granted. Do not look for another way to reach an endpoint that failed, such as a different client or a different key.
- If the user explicitly asks you to make a call even though you have no grant for it, make it once with `passport request`, show the response as it is, and stop. Never try another route.
- Delete and other writes need their own grant. Read access does not cover them.

## Answer format

When you list collections, answer only with a table of name and uid. Add no other comments, no owners, no dates, no summary.
