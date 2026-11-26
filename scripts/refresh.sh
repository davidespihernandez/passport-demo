#!/usr/bin/env bash
# Gets a new certificate (picks up approvals/revocations) and shows what the agent identity holds.
passport auth status >/dev/null 2>&1; passport refresh && passport whoami
