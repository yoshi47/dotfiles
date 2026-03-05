#!/bin/bash

# Bash Timeout Notifier Hook
# Detects when a bash command has timed out and notifies the user

# Read the input JSON from stdin or MESSAGE environment variable
INPUT="${MESSAGE:-$(cat)}"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    exit 0
fi

# Extract tool result content
TOOL_RESULT=$(echo "$INPUT" | jq -r '.tool_result // empty' 2>/dev/null)

# Check if the result contains timeout indicators
if echo "$TOOL_RESULT" | grep -qi -e "timed out" -e "timeout" -e "exceeded.*time" -e "command.*killed"; then
    # Play notification sound
    if [ -f "$HOME/Documents/notification.wav" ]; then
        afplay "$HOME/Documents/notification.wav" &
    fi

    # Output warning message to stderr
    echo "⚠️  Bashコマンドがタイムアウトしました" >&2

    exit 2
fi

exit 0
