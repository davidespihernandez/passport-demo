#!/usr/bin/env bash
# Gets a new certificate (picks up approvals/revocations) and shows what the agent identity holds.
passport refresh && passport whoami
