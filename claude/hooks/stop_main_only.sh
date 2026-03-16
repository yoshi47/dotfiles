#!/usr/bin/env bash
# Stop hook that only fires for the main agent (skips subagents).
# Usage: stop_main_only.sh <command> [args...]
# Reads hook JSON from stdin; if agent_id is present, it's a subagent → skip.

INPUT=$(cat)
AGENT_ID=$(echo "$INPUT" | jq -r '.agent_id // empty')

if [ -n "$AGENT_ID" ]; then
  exit 0
fi

exec "$@"
