#!/usr/bin/env bash
# Display session menu for clicking on status line

# Get all sessions
sessions=$(tmux list-sessions -F '#S' 2>/dev/null)

if [ -z "$sessions" ]; then
  exit 0
fi

# Build menu items dynamically
menu_items=""
while IFS= read -r session; do
  # Escape double quotes in session name
  escaped_session=$(echo "$session" | sed 's/"/\\"/g')
  menu_items+="\"$escaped_session\" \"switch-client -t '$escaped_session'\" \"\" "
done <<< "$sessions"

# Display menu at mouse position
eval "tmux display-menu -T 'Switch Session' -x M -y M $menu_items"
