#!/bin/sh
set -e

# Jump to next window matching a condition across all sessions.
# Usage: jump_flagged_window.sh alert|waiting
#   alert:   checks tmux native flags (#!~) and @app_alert
#   waiting: checks @app_waiting

current=$(tmux display-message -p '#{session_name}:#{window_index}')
target=""

case "${1:-}" in
  alert)
    # Native flags first
    target=$(tmux list-windows -a -F '#{window_flags} #{session_name}:#{window_index}' \
      | awk -v cur="$current" '/[#!~]/ && $2 != cur' \
      | head -1 \
      | awk '{print $2}')
    # Fallback to @app_alert
    if [ -z "$target" ]; then
      target=$(tmux list-windows -a -F '#{@app_alert} #{session_name}:#{window_index}' \
        | awk -v cur="$current" '$1 == "1" && $2 != cur' \
        | head -1 \
        | awk '{print $2}')
    fi
    msg="No alerted windows"
    ;;
  waiting)
    target=$(tmux list-windows -a -F '#{@app_waiting} #{session_name}:#{window_index}' \
      | awk -v cur="$current" '$1 == "1" && $2 != cur' \
      | head -1 \
      | awk '{print $2}')
    msg="No waiting windows"
    ;;
  *)
    echo "Usage: $0 alert|waiting" >&2; exit 1
    ;;
esac

if [ -n "$target" ]; then
  tmux switch-client -t "$target"
else
  tmux display-message "$msg"
fi
