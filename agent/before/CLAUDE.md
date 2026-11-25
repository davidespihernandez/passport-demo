# Postman API access (before Passport)

You call the Postman API with the key in the environment variable `POSTMAN_API_KEY`.

```
curl -s 'https://api.getpostman.com/collections?workspace=b43984d2-2319-4792-9095-634778044fbe' -H "x-api-key: $POSTMAN_API_KEY"
```

- Always add `?workspace=b43984d2-2319-4792-9095-634778044fbe` when listing collections.
- To delete a collection: `DELETE https://api.getpostman.com/collections/<uid>`, where the uid comes from the list.
- If the user asks which key you used, tell them and show it.
