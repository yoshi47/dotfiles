#!/bin/sh
set -e

# Find next alerted window across all sessions (activity=#, bell=!, silence=~)
# Skip only the actual current window (current session + window), not all windows marked with *
current=$(tmux display-message -p '#{session_name}:#{window_index}')
target=$(tmux list-windows -a -F '#{window_flags} #{session_name}:#{window_index}' \
  | awk -v cur="$current" '/[#!~]/ && $2 != cur' \
  | head -1 \
  | awk '{print $2}')

if [ -n "$target" ]; then
  tmux switch-client -t "$target"
else
  tmux display-message "No alerted windows"
fi
