#!/usr/bin/env bash
# Live, readable view of the local Passport Proxy log (one line per event).
# Drops the non-JSON noise (TLS health-probe errors) and the JSON envelope.
docker logs -f --since 1m pp-proxy-local 2>&1 | jq -R -r --unbuffered 'fromjson? | select(.Severity>=9) | "\(.Timestamp[11:19]) \(.SeverityText) \(.Body.Value) \([.Attributes[]?|"\(.Key)=\(.Value.Value)"]|join(" "))"'
